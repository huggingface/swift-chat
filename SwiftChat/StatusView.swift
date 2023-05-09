//
//  StatusView.swift
//
//  Initially created by Cyril Zakka on 1/12/23.
//

import SwiftUI

struct StatusView: View {
    @Binding var status: ModelState

    @State private var showErrorPopover = false
    
    func errorWithDetails(_ message: String, error: Error) -> any View {
        HStack {
            Text(message)
            Spacer()
            Button {
                showErrorPopover.toggle()
            } label: {
                Image(systemName: "info.circle")
            }.buttonStyle(.plain)
            .popover(isPresented: $showErrorPopover) {
                VStack {
                    Text(verbatim: "\(error)")
                    .lineLimit(nil)
                    .padding(.all, 5)
                    Button {
                        showErrorPopover.toggle()
                    } label: {
                        Text("Dismiss").frame(maxWidth: 200)
                    }
                    .padding(.bottom)
                }
                .frame(minWidth: 400, idealWidth: 400, maxWidth: 400)
                .fixedSize()
            }
        }
    }
    
    var body: some View {
        switch status {
        case .noModel: Text("Please, select a model").frame(height: 50)
        case .loading: Text("Loading model…").frame(height: 50)
        case .generating(let progress):
            let label = progress > 0 ? "Generating…" : "Preparing…"
            ProgressView(label, value: progress, total: 1).padding().frame(height: 50)
                .progressViewStyle(LinearProgressViewStyle(tint: Color.gray))
        case .ready(let tps):
            if let tps = tps {
                HStack {
                    Spacer()
                    Text("Ready")
                    Spacer()
                    Text("\(tps, specifier: "%.2f") tokens/s").padding(.trailing)
                }.frame(height: 50)
            } else {
                Text("Ready").frame(height: 50)
            }
            //        case .failed(let error):
            //            AnyView(errorWithDetails("Error message", error: error))
            //        }
        }
    }
}
