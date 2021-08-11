//
//  SafariWebExtensionHandler.swift
//  SafariTest
//
//  Created by Andrew Liakh on 11.08.21.
//

import SafariServices
import os.log

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        let usedMem = Int(memoryFootprint() ?? 0)
        let usedInKB = usedMem / 1024
        os_log(.default, "Memory used by Apple frameworks: \(usedInKB)KB")
        
        let availableMem = 6 * 1024 * 1024 - usedMem
        let availableInKB = availableMem / 1024
        os_log(.default, "Memory actually available to the extension: \(availableInKB)KB")
        
        // Exceeding the available memory by a tiny amount
        let memToAllocalte = availableMem + 512 * 1024
        
        os_log(.default, "Allocating a \(memToAllocalte / 1024)KB object to cause a crash")
        // Crash happens here (on a real device, not in simulator), because memory usage exceeds 6MB
        let array = [UInt8](repeating: 0, count: memToAllocalte)
        
        // Are we doing something wrong or is it the actual way this is designed to work? An extension just has ~1.5MB of memory to use?
    }
    
    func memoryFootprint() -> Float? {
        // The `TASK_VM_INFO_COUNT` and `TASK_VM_INFO_REV1_COUNT` macros are too
        // complex for the Swift C importer, so we have to define them ourselves.
        let TASK_VM_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let TASK_VM_INFO_REV1_COUNT = mach_msg_type_number_t(MemoryLayout.offset(of: \task_vm_info_data_t.min_address)! / MemoryLayout<integer_t>.size)
        var info = task_vm_info_data_t()
        var count = TASK_VM_INFO_COUNT
        let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
            }
        }
        guard
            kr == KERN_SUCCESS,
            count >= TASK_VM_INFO_REV1_COUNT
        else { return nil }
        
        let usedBytes = Float(info.phys_footprint)
        return usedBytes
        
    }

}
