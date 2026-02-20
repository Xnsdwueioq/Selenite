import SwiftUI
import PlaygroundSupport

struct TestView: View {
  @State private var pickedDate = Date()
  @State private var pickedSeconds = 0
  @State private var showSecondsPicker = false
  
  var body: some View {
    List {
      HStack(alignment: .center, spacing: 5) {
        DatePicker("", selection: $pickedDate, displayedComponents: [.date, .hourAndMinute])
          .labelsHidden()
        
        Button(action: { showSecondsPicker.toggle() }) {
          ZStack {
            Capsule()
              .foregroundStyle(Color(UIColor.tertiarySystemFill))
              .frame(width: 70, height: 35)
            
            Text(String(format: "%02d''", pickedSeconds))
              .foregroundColor(.primary)
              .monospacedDigit()
          }
        }
        .buttonStyle(.plain) // Чтобы кнопка не подсвечивала всю ячейку List
        .popover(isPresented: $showSecondsPicker) {
          // Окно с барабаном
          VStack {
            Picker("Секунды", selection: $pickedSeconds) {
              ForEach(0..<60) { second in
                Text("\(second)").tag(second)
              }
            }
            .pickerStyle(.wheel)
            .frame(width: 100, height: 150)
          }
          .presentationCompactAdaptation(.popover) // Важно для iPhone
        }
      }
    }
  }
}

PlaygroundPage.current.setLiveView(TestView())
