//
//  LogView.swift
//  Skinalyze
//
//  Created by Ali Haidar on 10/14/24.
//

import SwiftUI
import SwiftData

struct LogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var logs: [Result]
    
    var body: some View {
        
        List {
            let groupedLogs = groupLogsByDate(logs)
            
            ForEach(groupedLogs.keys.sorted(), id: \.self) { date in
                Section(header: Text(date, style: .date)) {
                    ForEach(groupedLogs[date]!, id: \.id) { log in
                        HStack {
                            if let imageString = log.analyzedImages1, let image = imageString.toImage() {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                            } else {
                                Text("No image available")
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("\(log.currentDate, format: Date.FormatStyle(date: .none, time: .shortened))")
                                    
                                    Spacer()
                                    let severityLevel = AcneSeverityLevel(rawValue: log.geaScale)!
                                    Text(severityLevel.description)
                                }
                                
                                Text("A few are present. Acne is infrequent and generally does not cause significant discomfort...")
                                    .lineLimit(3)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        
        //            .onAppear {
        //                printLogs()
        //            }
        
        
    }
    
    private func groupLogsByDate(_ logs: [Result]) -> [Date: [Result]] {
        var groupedLogs: [Date: [Result]] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" 
        
        for log in logs {
            let dateString = dateFormatter.string(from: log.currentDate)
            let date = dateFormatter.date(from: dateString)!
            groupedLogs[date, default: []].append(log)
        }
        
        return groupedLogs
    }
    
    private func printLogs() {
        print("Logs count: \(logs.count)")
        for log in logs {
            print("Log ID: \(log.id), Date: \(log.currentDate)")
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(logs[index])
            }
        }
    }
}

#Preview {
    LogView()
        .modelContainer(for: Result.self, inMemory: true)
}
