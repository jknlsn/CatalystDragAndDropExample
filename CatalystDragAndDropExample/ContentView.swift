import SwiftUI
import UniformTypeIdentifiers
import os

private let logger = Logger(subsystem: "DragDropTest", category: "UI")

struct ContentView: View {
    @State private var items = ["Item 1",
                                "Item 2",
                                "Item 3",
                                "Item 4",
                                "Item 5"]
    @State private var showPopover: Bool = false

    var body: some View {
        Button("Show List") {
            logger.debug("Opening popover")
            showPopover = true
        }
        .popover(isPresented: $showPopover) {
            ReorderableListView(items: $items)
                .frame(width: 400, height: 500)
        }
    }
}

extension String: @retroactive Identifiable {
    public var id: String {
        return self
    }
}

struct ReorderableListView: View {
    @Binding var items: [String]
    @State private var activeItem: String?
    @State private var hasChangedLocation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .opacity(activeItem == item && hasChangedLocation ? 0.5 : 1)
                        .onDrag {
                            logger.debug("Starting drag for item: \(item)")
                            activeItem = item
                            return NSItemProvider(object: item as NSString)
                        }
                        .onDrop(of: [.text], delegate: DragRelocateDelegate(
                            item: item,
                            items: items,
                            active: $activeItem,
                            hasChangedLocation: $hasChangedLocation
                        ) { from, to in
                            withAnimation {
                                items.move(fromOffsets: IndexSet(integer: from), toOffset: to)
                            }
                        })
                }
            }
        }
        .onDrop(of: [.text], delegate: DropOutsideDelegate(active: $activeItem))
    }
}

struct DragRelocateDelegate: DropDelegate {
    let item: String
    let items: [String]
    @Binding var active: String?
    @Binding var hasChangedLocation: Bool
    let moveAction: (Int, Int) -> Void

    func dropEntered(info: DropInfo) {
        logger.debug("Drop entered for item: \(item)")

        guard item != active,
              let current = active,
              let from = items.firstIndex(of: current),
              let to = items.firstIndex(of: item) else {
            return
        }

        hasChangedLocation = true

        if items[to] != current {
            moveAction(from, to > from ? to + 1 : to)
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        logger.debug("Drop performed for item: \(item)")
        hasChangedLocation = false
        active = nil
        return true
    }
}

struct DropOutsideDelegate: DropDelegate {
    @Binding var active: String?

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        active = nil
        return true
    }
}

#Preview {
    ContentView()
}
