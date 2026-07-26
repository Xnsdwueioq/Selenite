// TimerCore.swift
// FocusCore
// Created by Eyhciurmrn Zmpodackrl on 09.07.2026.

import Foundation

public enum TimerCore {
  public static func reduce(
    _ state: TimerState,
    _ event: TimerEvent,
    context: TimerContext
  ) -> (TimerState, [TimerEffect]) {
    let now = context.now
    switch (state.phase, event) {
      
      // MARK: - IDLE + START
    case (.idle, .start):
      var newState = state
      
      newState.phase = .work(index: 0)
      newState.workedIntervals = []
      newState.currentIntervalStart = now
      newState.cycleID = context.makeID()
      
      return (newState, effects(after: newState, notifications: .reschedule(now: now)))
      
      // MARK: - [WORK, SHORT_BREAK, LONG_BREAK] + PAUSE
    case (.work(index: _), .pause),
      (.shortBreak(afterIndex: _), .pause),
      (.longBreak, .pause):
      guard let intervalStart = state.currentIntervalStart else { return (state, []) }
      var newState = state
      
      newState.workedIntervals.append(DateInterval(start: intervalStart, end: now))
      newState.currentIntervalStart = nil
      
      return (newState, effects(after: newState, notifications: .cancel))
      
      // MARK: - [WORK, SHORT_BREAK, LONG_BREAK] + RESUME
    case (.work, .resume),
      (.shortBreak, .resume),
      (.longBreak, .resume):
      guard state.isPaused else { return (state, []) }
      var newState = state
      
      newState.currentIntervalStart = now
      
      return (newState, effects(after: newState, notifications: .reschedule(now: now)))
      
      // MARK: - WORK + BOUNDARY_REACHED
    case (.work(index: let index), .boundaryReached):
      var newState = state
      
      if let start = state.currentIntervalStart {
        newState.workedIntervals.append(DateInterval(start: start, end: now))
      }
      newState.completedIndices.insert(index)
      let completedSession = CompletedSession.create(
        from: newState,
        with: state.cycleID ?? context.makeID(),
        terminationReason: .completed,
        sessionIndex: index
      )
      
      let next = PhaseSequence.next(after: state.phase, config: state.config)
      newState = advance(newState, to: next, now: now, autoStart: state.config.autoAdvance)
      
      return (newState, effects(after: newState, notifications: .reschedule(now: now), saving: [completedSession]))
      
      // MARK: - [SHORT_BREAK, LONG_BREAK] + BOUNDARY_REACHED
    case (.shortBreak, .boundaryReached),
      (.longBreak, .boundaryReached):
      var newState = state
      
      if let start = state.currentIntervalStart {
        newState.workedIntervals.append(DateInterval(start: start, end: now))
      }
      
      let next = PhaseSequence.next(after: state.phase, config: state.config)
      newState = advance(newState, to: next, now: now, autoStart: state.config.autoAdvance)
      
      return (newState, effects(after: newState, notifications: .reschedule(now: now)))
      
      // MARK: - AWAITING + START
    case (.awaiting(next: let nextPhase), .start):
      var newState = state
      
      newState.workedIntervals = []
      newState.phase = nextPhase
      newState.currentIntervalStart = now
      
      return (newState, effects(after: newState, notifications: .reschedule(now: now)))
      
      // MARK: - ANY + RESTART
    case (_, .restartCycle):
      let newState = TimerState(config: state.config)
      
      return (newState, effects(after: newState, notifications: .cancel))
      
      // MARK: - [IDLE, AWAITING, WORK] + RENAME
    case (.idle, .rename(let newTitle)),
      (.awaiting(next: .work), .rename(let newTitle)),
      (.work(index: _), .rename(let newTitle)):
      var newState = state
      
      newState.sessionTitle = newTitle
      
      return (newState, effects(after: newState, notifications: .keep))
      
      // MARK: - TOGGLE
    case (_, .toggle):
      let nextEvent: TimerEvent
      
      switch state.phase {
      case .idle, .awaiting:
        nextEvent = .start
        
      case .work, .shortBreak, .longBreak:
        nextEvent = state.isPaused ? .resume : .pause
        
      case .finished:
        return (state, [])
      }
      
      return reduce(state, nextEvent, context: context)
      
      // MARK: - IDLE + SKIP_FORWARD
    case (.idle, .skipForward):
      var newState = state
      
      newState.currentIntervalStart = nil
      newState.workedIntervals = []
      newState.completedIndices.insert(0)
      
      let next = PhaseSequence.next(after: .work(index: 0), config: state.config)
      newState.phase = (next == .finished) ? .finished : .awaiting(next: next)
      
      return (newState, effects(after: newState, notifications: .cancel))
      
      // MARK: - AWAITING + SKIP_FORWARD
    case (.awaiting(next: let nextPhase), .skipForward):
      var newState = state
      
      if case .work(let index) = nextPhase {
        newState.completedIndices.insert(index)
      }
      
      let phaseAfterNext = PhaseSequence.next(after: nextPhase, config: state.config)
      newState = advance(newState, to: phaseAfterNext, now: now, autoStart: false)
      
      return (newState, effects(after: newState, notifications: .cancel))
      
      // MARK: - WORK + SKIP_FORWARD
    case (.work(index: let index), .skipForward):
      var newState = state
      
      if let start = state.currentIntervalStart {
        newState.workedIntervals.append(DateInterval(start: start, end: now))
      }
      newState.completedIndices.insert(index)
      let completedSession = CompletedSession.create(
        from: newState,
        with: state.cycleID ?? context.makeID(),
        terminationReason: .skipped,
        sessionIndex: index
      )
      
      let next = PhaseSequence.next(after: state.phase, config: state.config)
      newState = advance(newState, to: next, now: now, autoStart: false)   // скип не авто-стартует
      
      return (newState, effects(after: newState, notifications: .cancel, saving: [completedSession]))
      
      // MARK: - SHORT_BREAK + SKIP_FORWARD
    case (.shortBreak, .skipForward):
      var newState = state
      
      if let start = state.currentIntervalStart {
        newState.workedIntervals.append(DateInterval(start: start, end: now))
      }
      
      let next = PhaseSequence.next(after: state.phase, config: state.config)
      newState = advance(newState, to: next, now: now, autoStart: false)
      
      return (newState, effects(after: newState, notifications: .cancel))
      
      // MARK: - LONG_BREAK + SKIP_FORWARD
    case (.longBreak, .skipForward):
      var newState = state
      
      if let start = state.currentIntervalStart {
        newState.workedIntervals.append(DateInterval(start: start, end: now))
      }
      
      let next = PhaseSequence.next(after: state.phase, config: state.config)   // .finished
      newState = advance(newState, to: next, now: now, autoStart: false)

      return (newState, effects(after: newState, notifications: .cancel))

      // MARK: - FINISHED + SKIP_FORWARD
    case (.finished, .skipForward):
      let newState = TimerState(config: state.config)

      return (newState, effects(after: newState, notifications: .cancel))

      // MARK: - WORK + SKIP_BACKWARD
    case (.work(index: let index), .skipBackward(saveCurrent: let saveCurrent)):
      var newState = state
      
      // Сначала (опционально) фиксируем текущую попытку как завершённую сессию —
      // пока workedIntervals ещё несут открытый кусок.
      var completedSessions: [CompletedSession] = []
      if saveCurrent {
        if let start = state.currentIntervalStart {
          newState.workedIntervals.append(DateInterval(start: start, end: now))
        }
        let completedSession = CompletedSession.create(
          from: newState,
          with: state.cycleID ?? context.makeID(),
          terminationReason: .skipped,
          sessionIndex: index
        )
        completedSessions.append(completedSession)
      }
      
      // Затем сбрасываем попытку и уходим в ожидание той же фазы.
      newState.currentIntervalStart = nil
      newState.workedIntervals = []
      newState.phase = .awaiting(next: state.phase)
    
      return (newState, effects(after: newState, notifications: .cancel, saving: completedSessions))
      
      // MARK: - [SHORT_BREAK, LONG_BREAK] + SKIP_BACKWARD
    case (.shortBreak, .skipBackward),
      (.longBreak, .skipBackward):
      var newState = state
      
      newState.currentIntervalStart = nil
      newState.workedIntervals = []
      newState.phase = .awaiting(next: state.phase)
      
      return (newState, effects(after: newState, notifications: .cancel))
      
      // MARK: - AWAITING + SKIP_BACKWARD
    case (.awaiting(next: let phase), .skipBackward):
      guard let previous = PhaseSequence.previous(before: phase, config: state.config) else {
        return (state, [])
      }
      var newState = state
      
      if case .work(let index) = previous {
        newState.completedIndices.remove(index)
      }
      
      newState.currentIntervalStart = nil
      newState.workedIntervals = []
      newState.phase = .awaiting(next: previous)
      
      return (newState, effects(after: newState, notifications: .cancel))
      
      // MARK: - DEFAULT
    default:
      return (state, [])
    }
  }
  
  // MARK: - Воспроизведение прошедших сессий
  
  public static func reconciled(
    _ state: TimerState,
    context: TimerContext
  ) -> (TimerState, [TimerEffect]) {
    var currentState = state
    var completedSessions: [CompletedSession] = []
    
    while let boundaryDate = currentState.currentBoundaryDate,
          boundaryDate <= context.now {
      let currentContext = TimerContext(now: boundaryDate, makeID: context.makeID)
      let (nextState, currentEffects) = reduce(currentState, .boundaryReached, context: currentContext)
      currentState = nextState
      
      for effect in currentEffects {
        if case .saveCompleted(let completedSession) = effect {
          completedSessions.append(completedSession)
        }
      }
    }
    guard currentState != state else { return (state, []) }
    
    let effects: [TimerEffect] = effects(
      after: currentState,
      notifications: .reschedule(now: context.now),
      saving: completedSessions
    )
    return (currentState, effects)
  }
}

// MARK: - Веер эффектов

extension TimerCore {
  /// Что сделать с расписанием локальных уведомлений при переходе.
  enum Notifications {
    /// Не трогать расписание (переход не меняет тайминг — напр. `rename`).
    case keep
    /// Отменить все запланированные границы (уход из бегущей фазы).
    case cancel
    /// Перепланировать под новое состояние. Если впереди границ нет
    /// (`awaiting`/`finished`), веер сам вырождается в `.cancelNotifications`.
    case reschedule(now: Date)
  }
  
  /// Канонический веер эффектов после перехода. Единственный источник правды
  /// о составе и порядке эффектов.
  ///
  /// Порядок: сначала записи (снапшот, история, календарь), затем уведомления,
  /// затем push-читатели (Live Activity, часы), и `reloadWidgets` — последним,
  /// чтобы pull-читатель увидел уже свежие снапшот и историю.
  static func effects(
    after state: TimerState,
    notifications: Notifications,
    saving completed: [CompletedSession] = []
  ) -> [TimerEffect] {
    var effects: [TimerEffect] = [.persistSnapshot(state)]
    
    for session in completed {
      effects.append(.saveCompleted(session))
      effects.append(.addCalendarEvent(session))
    }
    
    switch notifications {
    case .keep:
      break
    case .cancel:
      effects.append(.cancelNotifications)
    case .reschedule(let now):
      let boundaries = Schedule.boundaries(for: state, now: now)
      // Пустой план — это «границ впереди нет», семантически отмена,
      // а не перепланирование в никуда.
      effects.append(boundaries.isEmpty ? .cancelNotifications : .rescheduleNotifications(boundaries))
    }
    
    effects.append(.syncLiveActivity(state))
    effects.append(.pushToWatch(state))
    effects.append(.reloadWidgets)
    
    return effects
  }
}

// MARK: - Применение перехода к состоянию

private extension TimerCore {
  /// Применяет переход в `nextPhase` к состоянию: сбрасывает якоря прошлой фазы
  /// и расставляет якоря новой в зависимости от режима.
  ///
  /// - `.finished` — терминал: фаза не тикает, якорь не ставится.
  /// - `autoStart == true` — новая фаза стартует немедленно (якорь = `now`).
  /// - `autoStart == false` — уходим в `.awaiting(next:)` без якорей, ждём `start`.
  static func advance(_ state: TimerState, to nextPhase: Phase, now: Date, autoStart: Bool) -> TimerState {
    var newState = state
    newState.workedIntervals = []
    if nextPhase == .finished {
      newState.phase = .finished
      newState.currentIntervalStart = nil
    } else if autoStart {
      newState.phase = nextPhase
      newState.currentIntervalStart = now
    } else {
      newState.phase = .awaiting(next: nextPhase)
      newState.currentIntervalStart = nil
    }
    return newState
  }
}
