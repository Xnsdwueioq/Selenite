// TimerCoreTests.swift
// FocusCoreTests

import Foundation
import Testing
@testable import FocusCore

@Suite struct TimerCoreTests {

  // MARK: - Фикстуры (детерминированные: фиксированное время + конфиг)

  static let now = Date(timeIntervalSince1970: 1_720_000_000)
  static let config = TimerConfig(
    sessionCount: 4,
    sessionDuration: 25,          // в тестах трактуем как секунды — цифры удобные
    shortBreaksEnabled: true,
    shortBreakDuration: 30,
    longBreaksEnabled: true,
    longBreakDuration: 60
  )

  /// Свежее состояние в простое.
  var idle: TimerState { TimerState(config: Self.config) }

  /// Работа №0 идёт, кусок открыт в `start`.
  func running(start: Date) -> TimerState {
    var s = idle
    s.phase = .work(index: 0)
    s.currentIntervalStart = start
    return s
  }

  /// Фиксированный id цикла — детерминизм вместо случайного `UUID()`.
  static let cycleID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

  /// Контекст с зафиксированными «сейчас» и фабрикой id.
  func ctx(_ now: Date = TimerCoreTests.now) -> TimerContext {
    TimerContext(now: now, makeID: { TimerCoreTests.cycleID })
  }

  // MARK: - start

  @Test func startFromIdleEntersWorkAndOpensInterval() {
    let (s, effects) = TimerCore.reduce(idle, .start, context: ctx(Self.now))

    #expect(s.phase == .work(index: 0))
    #expect(s.currentIntervalStart == Self.now)   // кусок открыт «сейчас»
    #expect(s.workedIntervals.isEmpty)            // закрытых кусков ещё нет
    #expect(!s.isPaused)
    // веер эффектов на старте
    #expect(effects.contains(.persistSnapshot(s)))
    #expect(effects.contains(.reloadWidgets))
    #expect(effects.contains(.pushToWatch(s)))
  }

  // MARK: - pause

  @Test func pauseClosesIntervalAndFreezesRemaining() {
    let state = running(start: Self.now)
    let pauseAt = Self.now.addingTimeInterval(10)      // поработали 10 сек

    let (s, effects) = TimerCore.reduce(state, .pause, context: ctx(pauseAt))

    #expect(s.currentIntervalStart == nil)             // открытого куска больше нет
    #expect(s.isPaused)
    #expect(s.workedIntervals == [DateInterval(start: Self.now, end: pauseAt)])
    #expect(effects.contains(.cancelNotifications))

    // на паузе remaining заморожен: 25 − 10 = 15, независимо от now
    #expect(s.remaining(at: pauseAt.addingTimeInterval(9_999)) == 15)
  }

  // MARK: - resume

  @Test func resumeOpensNewIntervalAndPauseIsNotCounted() {
    var paused = running(start: Self.now)
    paused.workedIntervals = [DateInterval(start: Self.now, end: Self.now.addingTimeInterval(10))]
    paused.currentIntervalStart = nil                  // на паузе
    #expect(paused.isPaused)

    let resumeAt = Self.now.addingTimeInterval(300)     // вернулись через 5 минут паузы
    let (s, _) = TimerCore.reduce(paused, .resume, context: ctx(resumeAt))

    #expect(s.currentIntervalStart == resumeAt)         // открыт новый кусок
    #expect(!s.isPaused)
    // пауза (5 мин) НЕ съела время фазы: отработано только 10 закрытых сек → осталось 15
    #expect(s.remaining(at: resumeAt) == 15)
  }

  // MARK: - перерыв тоже паузится и резюмится (проверка симметрии pause/resume)

  @Test func shortBreakCanBePausedAndResumed() {
    var breakState = idle
    breakState.phase = .shortBreak(afterIndex: 0)
    breakState.currentIntervalStart = Self.now

    let (paused, _) = TimerCore.reduce(breakState, .pause, context: ctx(Self.now.addingTimeInterval(5)))
    #expect(paused.isPaused)
    #expect(paused.currentIntervalStart == nil)

    let (resumed, _) = TimerCore.reduce(paused, .resume, context: ctx(Self.now.addingTimeInterval(100)))
    #expect(!resumed.isPaused)
    #expect(resumed.currentIntervalStart == Self.now.addingTimeInterval(100))
  }

  // MARK: - неподходящие события ничего не делают

  @Test func pauseFromIdleIsNoOp() {
    let (s, effects) = TimerCore.reduce(idle, .pause, context: ctx(Self.now))
    #expect(s == idle)          // состояние не изменилось
    #expect(effects.isEmpty)    // поручений нет
  }

  @Test func resumeWhileRunningIsNoOp() {
    let state = running(start: Self.now)   // идёт, не на паузе
    let (s, effects) = TimerCore.reduce(state, .resume, context: ctx(Self.now.addingTimeInterval(5)))
    #expect(s == state)
    #expect(effects.isEmpty)
  }

  // MARK: - boundaryReached: переходы по границе фазы

  // Ручной режим (умолчание): работа кончилась → ждём play перед следующей фазой.
  @Test func workBoundaryManualGoesToAwaitingShortBreak() {
    let state = running(start: Self.now)                       // work(0) идёт
    let (s, _) = TimerCore.reduce(state, .boundaryReached, context: ctx(Self.now.addingTimeInterval(25)))

    #expect(s.phase == .awaiting(next: .shortBreak(afterIndex: 0)))
    #expect(s.completedIndices == [0])
    #expect(s.workedIntervals.isEmpty)                         // сброшены для следующей фазы
    #expect(s.currentIntervalStart == nil)                     // не тикаем, ждём play
  }

  // Авто-режим: работа кончилась → сразу стартует короткий перерыв.
  @Test func workBoundaryAutoStartsShortBreak() {
    var cfg = Self.config
    cfg.autoAdvance = true
    var state = TimerState(config: cfg)
    state.phase = .work(index: 0)
    state.currentIntervalStart = Self.now
    let boundary = Self.now.addingTimeInterval(25)

    let (s, _) = TimerCore.reduce(state, .boundaryReached, context: ctx(boundary))

    #expect(s.phase == .shortBreak(afterIndex: 0))
    #expect(s.currentIntervalStart == boundary)                // новый кусок открыт сразу
    #expect(s.workedIntervals.isEmpty)
  }

  // Последняя сессия (index == sessionCount-1) → длинный перерыв.
  @Test func lastWorkBoundaryGoesToLongBreak() {
    var state = idle
    state.phase = .work(index: 3)                              // sessionCount == 4 → последняя
    state.currentIntervalStart = Self.now
    let (s, _) = TimerCore.reduce(state, .boundaryReached, context: ctx(Self.now.addingTimeInterval(25)))

    #expect(s.phase == .awaiting(next: .longBreak))
    #expect(s.completedIndices.contains(3))
  }

  // Короткий перерыв кончился → следующая работа.
  @Test func shortBreakBoundaryGoesToNextWork() {
    var state = idle
    state.phase = .shortBreak(afterIndex: 0)
    state.currentIntervalStart = Self.now
    let (s, _) = TimerCore.reduce(state, .boundaryReached, context: ctx(Self.now.addingTimeInterval(30)))

    #expect(s.phase == .awaiting(next: .work(index: 1)))
  }

  // Длинный перерыв кончился → finished, БЕЗ открытия куска (фиксируем фикс longBreak).
  @Test func longBreakBoundaryFinishesWithoutOpeningInterval() {
    var cfg = Self.config
    cfg.autoAdvance = true                                     // даже в авто — не тикаем
    var state = TimerState(config: cfg)
    state.phase = .longBreak
    state.currentIntervalStart = Self.now
    let (s, _) = TimerCore.reduce(state, .boundaryReached, context: ctx(Self.now.addingTimeInterval(60)))

    #expect(s.phase == .finished)
    #expect(s.currentIntervalStart == nil)                     // терминальная фаза не тикает
    #expect(s.workedIntervals.isEmpty)
  }

  // Последняя сессия + длинный перерыв выключен → сразу finished.
  @Test func lastWorkBoundaryFinishesWhenLongBreakDisabled() {
    var cfg = Self.config
    cfg.longBreaksEnabled = false
    var state = TimerState(config: cfg)
    state.phase = .work(index: 3)
    state.currentIntervalStart = Self.now
    let (s, _) = TimerCore.reduce(state, .boundaryReached, context: ctx(Self.now.addingTimeInterval(25)))

    #expect(s.phase == .finished)
    #expect(s.currentIntervalStart == nil)
  }

  // MARK: - skipForward: всегда в awaiting (autoAdvance игнорируется), индикатор заполняется

  // Скип работы → ждём следующую фазу, текущая сессия помечена завершённой.
  @Test func skipWorkGoesToAwaitingAndMarksSession() {
    let state = running(start: Self.now)                       // work(0) идёт
    let (s, _) = TimerCore.reduce(state, .skipForward(saveCurrent: false), context: ctx(Self.now.addingTimeInterval(5)))

    #expect(s.phase == .awaiting(next: .shortBreak(afterIndex: 0)))
    #expect(s.completedIndices == [0])                         // индикатор заполнен
    #expect(s.currentIntervalStart == nil)                     // не тикаем
    #expect(s.workedIntervals.isEmpty)
  }

  // Скип работы даже при autoAdvance = true всё равно уходит в awaiting (не авто-стартует).
  @Test func skipIgnoresAutoAdvance() {
    var cfg = Self.config
    cfg.autoAdvance = true
    var state = TimerState(config: cfg)
    state.phase = .work(index: 0)
    state.currentIntervalStart = Self.now

    let (s, _) = TimerCore.reduce(state, .skipForward(saveCurrent: false), context: ctx(Self.now.addingTimeInterval(5)))

    #expect(s.phase == .awaiting(next: .shortBreak(afterIndex: 0)))
    #expect(s.currentIntervalStart == nil)                     // именно awaiting, а не запуск
  }

  // Скип короткого перерыва → ждём следующую работу.
  @Test func skipShortBreakGoesToAwaitingNextWork() {
    var state = idle
    state.phase = .shortBreak(afterIndex: 0)
    state.currentIntervalStart = Self.now
    let (s, _) = TimerCore.reduce(state, .skipForward(saveCurrent: false), context: ctx(Self.now.addingTimeInterval(5)))

    #expect(s.phase == .awaiting(next: .work(index: 1)))
  }

  // Скип последней работы (длинный перерыв выключен) → finished, без awaiting(next: .finished).
  @Test func skipLastWorkFinishesWhenLongBreakDisabled() {
    var cfg = Self.config
    cfg.longBreaksEnabled = false
    var state = TimerState(config: cfg)
    state.phase = .work(index: 3)
    state.currentIntervalStart = Self.now
    let (s, _) = TimerCore.reduce(state, .skipForward(saveCurrent: false), context: ctx(Self.now.addingTimeInterval(5)))

    #expect(s.phase == .finished)
    #expect(s.currentIntervalStart == nil)
  }

  // Скип из ожидания длинного перерыва → finished (а НЕ awaiting(next: .finished)) — фиксируем finished-guard.
  @Test func skipFromAwaitingLongBreakFinishes() {
    var state = idle
    state.phase = .awaiting(next: .longBreak)
    let (s, _) = TimerCore.reduce(state, .skipForward(saveCurrent: false), context: ctx(Self.now))

    #expect(s.phase == .finished)
  }

  // Скип из ожидания работы помечает пропущенную сессию (её индекс, не index-1).
  @Test func skipFromAwaitingWorkMarksThatSession() {
    var state = idle
    state.phase = .awaiting(next: .work(index: 2))
    state.completedIndices = [0, 1]
    let (s, _) = TimerCore.reduce(state, .skipForward(saveCurrent: false), context: ctx(Self.now))

    #expect(s.completedIndices == [0, 1, 2])                   // помечена именно работа 2
    #expect(s.phase == .awaiting(next: .shortBreak(afterIndex: 2)))
  }

  // MARK: - edge-cases: одна сессия и выключенные перерывы

  // idle + skip (обычный конфиг) → ждём короткий перерыв, сессия 0 помечена.
  @Test func skipFromIdleGoesToAwaitingShortBreak() {
    let (s, _) = TimerCore.reduce(idle, .skipForward(saveCurrent: false), context: ctx(Self.now))
    #expect(s.phase == .awaiting(next: .shortBreak(afterIndex: 0)))
    #expect(s.completedIndices == [0])
  }

  // Одна сессия + длинный перерыв ВКЛ: idle + skip → ждём длинный перерыв.
  @Test func skipFromIdleSingleSessionGoesToLongBreak() {
    var cfg = Self.config
    cfg.sessionCount = 1
    let (s, _) = TimerCore.reduce(TimerState(config: cfg), .skipForward(saveCurrent: false), context: ctx(Self.now))
    #expect(s.phase == .awaiting(next: .longBreak))
    #expect(s.completedIndices == [0])
  }

  // Одна сессия + длинный перерыв ВЫКЛ: idle + skip → сразу finished.
  @Test func skipFromIdleSingleSessionNoLongBreakFinishes() {
    var cfg = Self.config
    cfg.sessionCount = 1
    cfg.longBreaksEnabled = false
    let (s, _) = TimerCore.reduce(TimerState(config: cfg), .skipForward(saveCurrent: false), context: ctx(Self.now))
    #expect(s.phase == .finished)
    #expect(s.completedIndices == [0])
  }

  // Короткие перерывы выключены: граница работы → сразу следующая работа (перерыв пропущен).
  @Test func workBoundarySkipsShortBreakWhenDisabled() {
    var cfg = Self.config
    cfg.shortBreaksEnabled = false
    var state = TimerState(config: cfg)
    state.phase = .work(index: 0)
    state.currentIntervalStart = Self.now
    let (s, _) = TimerCore.reduce(state, .boundaryReached, context: ctx(Self.now.addingTimeInterval(25)))
    #expect(s.phase == .awaiting(next: .work(index: 1)))
  }

  // Одна сессия: граница единственной работы → длинный перерыв.
  @Test func singleSessionWorkBoundaryGoesToLongBreak() {
    var cfg = Self.config
    cfg.sessionCount = 1
    var state = TimerState(config: cfg)
    state.phase = .work(index: 0)
    state.currentIntervalStart = Self.now
    let (s, _) = TimerCore.reduce(state, .boundaryReached, context: ctx(Self.now.addingTimeInterval(25)))
    #expect(s.phase == .awaiting(next: .longBreak))
    #expect(s.completedIndices == [0])
  }

  // MARK: - restartCycle: выход из тупика в свежий цикл

  // finished + restartCycle → чистый idle, настройки сохранены.
  @Test func restartCycleFromFinishedResetsEverything() {
    var state = TimerState(config: Self.config)
    state.phase = .finished
    state.completedIndices = [0, 1, 2, 3]
    state.sessionTitle = "Эссе"
    state.workedIntervals = [DateInterval(start: Self.now, end: Self.now.addingTimeInterval(25))]

    let (s, effects) = TimerCore.reduce(state, .restartCycle, context: ctx(Self.now))

    #expect(s.phase == .idle)
    #expect(s.completedIndices.isEmpty)
    #expect(s.sessionTitle == "Selenite")
    #expect(s.workedIntervals.isEmpty)
    #expect(s.currentIntervalStart == nil)
    #expect(s.config == Self.config)              // настройки не сбрасываются
    #expect(effects.contains(.cancelNotifications))
  }

  // Рестарт из середины цикла (идущей работы) тоже даёт чистый idle.
  @Test func restartCycleFromRunningWorkResets() {
    let state = running(start: Self.now)          // work(0) идёт
    let (s, _) = TimerCore.reduce(state, .restartCycle, context: ctx(Self.now))
    #expect(s.phase == .idle)
    #expect(s.currentIntervalStart == nil)
    #expect(s.completedIndices.isEmpty)
  }

  // MARK: - skipBackward: рестарт текущей / шаг назад / no-op

  // Идущая работа → рестарт текущей (awaiting той же), попытка отброшена, прогресс не тронут.
  @Test func skipBackFromRunningWorkRestartsCurrent() {
    var state = idle
    state.phase = .work(index: 2)
    state.currentIntervalStart = Self.now
    state.completedIndices = [0, 1]
    let (s, _) = TimerCore.reduce(state, .skipBackward(saveCurrent: false), context: ctx(Self.now.addingTimeInterval(10)))

    #expect(s.phase == .awaiting(next: .work(index: 2)))   // та же сессия, ждём play
    #expect(s.currentIntervalStart == nil)
    #expect(s.workedIntervals.isEmpty)                     // текущая попытка отброшена
    #expect(s.completedIndices == [0, 1])                  // прогресс не меняется
  }

  // Идущий короткий перерыв → рестарт текущего перерыва.
  @Test func skipBackFromRunningShortBreakRestartsCurrent() {
    var state = idle
    state.phase = .shortBreak(afterIndex: 1)
    state.currentIntervalStart = Self.now
    let (s, _) = TimerCore.reduce(state, .skipBackward(saveCurrent: false), context: ctx(Self.now.addingTimeInterval(5)))
    #expect(s.phase == .awaiting(next: .shortBreak(afterIndex: 1)))
    #expect(s.currentIntervalStart == nil)
  }

  // Идущий длинный перерыв → рестарт текущего.
  @Test func skipBackFromRunningLongBreakRestartsCurrent() {
    var state = idle
    state.phase = .longBreak
    state.currentIntervalStart = Self.now
    let (s, _) = TimerCore.reduce(state, .skipBackward(saveCurrent: false), context: ctx(Self.now.addingTimeInterval(5)))
    #expect(s.phase == .awaiting(next: .longBreak))
  }

  // awaiting(next: work) → шаг назад на предыдущий перерыв; work-индекс НЕ снимаем (возвращаемся к перерыву).
  @Test func skipBackFromAwaitingWorkGoesToPreviousBreak() {
    var state = idle
    state.phase = .awaiting(next: .work(index: 1))
    state.completedIndices = [0]
    let (s, _) = TimerCore.reduce(state, .skipBackward(saveCurrent: false), context: ctx(Self.now))
    #expect(s.phase == .awaiting(next: .shortBreak(afterIndex: 0)))
    #expect(s.completedIndices == [0])
  }

  // awaiting(next: shortBreak) → шаг назад на работу; её индекс снимается (будем переделывать).
  @Test func skipBackFromAwaitingBreakGoesToWorkAndUnmarks() {
    var state = idle
    state.phase = .awaiting(next: .shortBreak(afterIndex: 0))
    state.completedIndices = [0]
    let (s, _) = TimerCore.reduce(state, .skipBackward(saveCurrent: false), context: ctx(Self.now))
    #expect(s.phase == .awaiting(next: .work(index: 0)))
    #expect(s.completedIndices.isEmpty)                    // work 0 снята с индикатора
  }

  // Короткие перерывы выключены: awaiting(next: work) → шаг назад прямо на предыдущую работу.
  @Test func skipBackNoShortBreaksStepsBetweenWork() {
    var cfg = Self.config
    cfg.shortBreaksEnabled = false
    var state = TimerState(config: cfg)
    state.phase = .awaiting(next: .work(index: 2))
    state.completedIndices = [0, 1]
    let (s, _) = TimerCore.reduce(state, .skipBackward(saveCurrent: false), context: ctx(Self.now))
    #expect(s.phase == .awaiting(next: .work(index: 1)))
    #expect(s.completedIndices == [0])                     // work 1 снята
  }

  // awaiting(next: longBreak) → шаг назад на последнюю работу, её индекс снимается.
  @Test func skipBackFromAwaitingLongBreakGoesToLastWork() {
    var state = idle
    state.phase = .awaiting(next: .longBreak)
    state.completedIndices = [0, 1, 2, 3]
    let (s, _) = TimerCore.reduce(state, .skipBackward(saveCurrent: false), context: ctx(Self.now))
    #expect(s.phase == .awaiting(next: .work(index: 3)))
    #expect(s.completedIndices == [0, 1, 2])               // work 3 снята
  }

  // Край: awaiting(next: work(0)) → предыдущей нет (nil) → no-op.
  @Test func skipBackFromAwaitingFirstWorkIsNoOp() {
    var state = idle
    state.phase = .awaiting(next: .work(index: 0))
    let (s, effects) = TimerCore.reduce(state, .skipBackward(saveCurrent: false), context: ctx(Self.now))
    #expect(s == state)
    #expect(effects.isEmpty)
  }

  // idle + skipBackward → no-op.
  @Test func skipBackFromIdleIsNoOp() {
    let (s, effects) = TimerCore.reduce(idle, .skipBackward(saveCurrent: false), context: ctx(Self.now))
    #expect(s == idle)
    #expect(effects.isEmpty)
  }

  // finished + skipBackward → no-op.
  @Test func skipBackFromFinishedIsNoOp() {
    var state = idle
    state.phase = .finished
    let (s, effects) = TimerCore.reduce(state, .skipBackward(saveCurrent: false), context: ctx(Self.now))
    #expect(s == state)
    #expect(effects.isEmpty)
  }

  // MARK: - cycleID: рождается на старте цикла, живёт весь цикл

  // start из idle чеканит новый cycleID (детерминированно из контекста).
  @Test func startMintsCycleID() {
    let (s, _) = TimerCore.reduce(idle, .start, context: ctx())
    #expect(s.cycleID == Self.cycleID)
  }

  // cycleID не меняется на границе фазы — вся цепочка одного цикла несёт один id.
  @Test func cycleIDSurvivesBoundary() {
    let (started, _) = TimerCore.reduce(idle, .start, context: ctx())
    let (afterBoundary, _) = TimerCore.reduce(started, .boundaryReached, context: ctx(Self.now.addingTimeInterval(25)))
    #expect(afterBoundary.cycleID == Self.cycleID)
  }

  // restartCycle обнуляет cycleID — следующий start отчеканит новый.
  @Test func restartCycleClearsCycleID() {
    let (started, _) = TimerCore.reduce(idle, .start, context: ctx())
    let (restarted, _) = TimerCore.reduce(started, .restartCycle, context: ctx())
    #expect(restarted.cycleID == nil)
  }

  /// Достаёт `CompletedSession` из эффекта `.saveCompleted`, если он есть.
  private func savedSession(in effects: [TimerEffect]) -> CompletedSession? {
    for effect in effects {
      if case .saveCompleted(let session) = effect { return session }
    }
    return nil
  }

  /// Фабрика РАЗНЫХ id по очереди — чтобы отличить «отчеканен на старте»
  /// от «отчеканен заново при сохранении». (`@unchecked` — тест однопоточный.)
  private final class SequentialIDs: @unchecked Sendable {
    private let ids: [UUID]
    private var i = 0
    init(_ ids: [UUID]) { self.ids = ids }
    func next() -> UUID {
      defer { i += 1 }
      return ids[Swift.min(i, ids.count - 1)]
    }
  }

  // ГЛАВНЫЙ инвариант: две завершённые сессии ОДНОГО цикла несут один cycleID —
  // тот, что отчеканен на старте. Фабрика отдаёт РАЗНЫЕ id, поэтому баг
  // `context.makeID()` вместо `state.cycleID` дал бы двум сессиям разные id → красный.
  @Test func sessionsOfSameCycleShareCycleID() {
    let idA = UUID(uuidString: "00000000-0000-0000-0000-0000000000AA")!
    let idB = UUID(uuidString: "00000000-0000-0000-0000-0000000000BB")!
    let idC = UUID(uuidString: "00000000-0000-0000-0000-0000000000CC")!
    let gen = SequentialIDs([idA, idB, idC])
    func c(_ now: Date) -> TimerContext {
      TimerContext(now: now, makeID: { gen.next() })
    }

    // start → work(0); cycleID чеканится ЕДИНОЖДЫ здесь → idA
    let (s1, _) = TimerCore.reduce(idle, .start, context: c(Self.now))
    // граница work(0) → первая сессия
    let (s2, e2) = TimerCore.reduce(s1, .boundaryReached, context: c(Self.now.addingTimeInterval(25)))
    // play → перерыв идёт (awaiting+start id НЕ чеканит)
    let (s3, _) = TimerCore.reduce(s2, .start, context: c(Self.now.addingTimeInterval(25)))
    // граница перерыва → work(1) ожидает (перерыв сессию НЕ замораживает)
    let (s4, _) = TimerCore.reduce(s3, .boundaryReached, context: c(Self.now.addingTimeInterval(55)))
    // play → work(1) идёт
    let (s5, _) = TimerCore.reduce(s4, .start, context: c(Self.now.addingTimeInterval(55)))
    // граница work(1) → вторая сессия
    let (_, e6) = TimerCore.reduce(s5, .boundaryReached, context: c(Self.now.addingTimeInterval(80)))

    let first = savedSession(in: e2)
    let second = savedSession(in: e6)

    #expect(first?.cycleID == idA)               // id со старта, не заново
    #expect(second?.cycleID == idA)
    #expect(first?.cycleID == second?.cycleID)   // один цикл — один id
    #expect(first?.sessionIndex == 0)
    #expect(second?.sessionIndex == 1)
  }
}
