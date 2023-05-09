//
//  CoreProfileSessionTapModels.swift
//  APMr
//
//  Created by 任玉乾 on 2023/5/9.
//

import Foundation

extension IInstruments.CoreProfileSessionTap {
    struct ModelV1 {
        let entries: [KCData]
    }
    
    struct ModelV2 {
        let threadMap: [UInt64 : KDThreadMap]
        let entries: [KDEBUGEntry]
    }
    
    struct ModelV4 {
        let entries: [KDEBUGEntry]
    }
}

extension IInstruments.CoreProfileSessionTap {
    enum KT: UInt32 {
        case KCDATA_TYPE_INVALID = 0x0
        case KCDATA_TYPE_STRING_DESC = 0x1
        case KCDATA_TYPE_UINT32_DESC = 0x2
        case KCDATA_TYPE_UINT64_DESC = 0x3
        case KCDATA_TYPE_INT32_DESC = 0x4
        case KCDATA_TYPE_INT64_DESC = 0x5
        case KCDATA_TYPE_BINDATA_DESC = 0x6
        case KCDATA_TYPE_ARRAY = 0x11
        case KCDATA_TYPE_TYPEDEFINITION = 0x12
        case KCDATA_TYPE_CONTAINER_BEGIN = 0x13
        case KCDATA_TYPE_CONTAINER_END = 0x14
        
        case KCDATA_TYPE_ARRAY_PAD0 = 0x20
        case KCDATA_TYPE_ARRAY_PAD1 = 0x21
        case KCDATA_TYPE_ARRAY_PAD2 = 0x22
        case KCDATA_TYPE_ARRAY_PAD3 = 0x23
        case KCDATA_TYPE_ARRAY_PAD4 = 0x24
        case KCDATA_TYPE_ARRAY_PAD5 = 0x25
        case KCDATA_TYPE_ARRAY_PAD6 = 0x26
        case KCDATA_TYPE_ARRAY_PAD7 = 0x27
        case KCDATA_TYPE_ARRAY_PAD8 = 0x28
        case KCDATA_TYPE_ARRAY_PAD9 = 0x29
        case KCDATA_TYPE_ARRAY_PADa = 0x2a
        case KCDATA_TYPE_ARRAY_PADb = 0x2b
        case KCDATA_TYPE_ARRAY_PADc = 0x2c
        case KCDATA_TYPE_ARRAY_PADd = 0x2d
        case KCDATA_TYPE_ARRAY_PADe = 0x2e
        case KCDATA_TYPE_ARRAY_PADf = 0x2f
        
        case KCDATA_TYPE_LIBRARY_LOADINFO = 0x30
        case KCDATA_TYPE_LIBRARY_LOADINFO64 = 0x31
        case KCDATA_TYPE_TIMEBASE = 0x32
        case KCDATA_TYPE_MACH_ABSOLUTE_TIME = 0x33
        case KCDATA_TYPE_TIMEVAL = 0x34
        case KCDATA_TYPE_USECS_SINCE_EPOCH = 0x35
        case KCDATA_TYPE_PID = 0x36
        case KCDATA_TYPE_PROCNAME = 0x37
        case KCDATA_TYPE_NESTED_KCDATA = 0x38
        
        case STACKSHOT_KCTYPE_IO_STATISTICS = 0x901
        case STACKSHOT_KCCONTAINER_TASK = 0x903
        case STACKSHOT_KCCONTAINER_THREAD = 0x904
        case STACKSHOT_KCTYPE_TASK_SNAPSHOT = 0x905
        case STACKSHOT_KCTYPE_THREAD_SNAPSHOT = 0x906
        case STACKSHOT_KCTYPE_DONATING_PIDS = 0x907
        case STACKSHOT_KCTYPE_SHAREDCACHE_LOADINFO = 0x908
        case STACKSHOT_KCTYPE_THREAD_NAME = 0x909
        case STACKSHOT_KCTYPE_KERN_STACKFRAME = 0x90A
        case STACKSHOT_KCTYPE_KERN_STACKFRAME64 = 0x90B
        case STACKSHOT_KCTYPE_USER_STACKFRAME = 0x90C
        case STACKSHOT_KCTYPE_USER_STACKFRAME64 = 0x90D
        case STACKSHOT_KCTYPE_BOOTARGS = 0x90E
        case STACKSHOT_KCTYPE_OSVERSION = 0x90F
        case STACKSHOT_KCTYPE_KERN_PAGE_SIZE = 0x910
        case STACKSHOT_KCTYPE_JETSAM_LEVEL = 0x911
        case STACKSHOT_KCTYPE_DELTA_SINCE_TIMESTAMP = 0x912
        case STACKSHOT_KCTYPE_KERN_STACKLR = 0x913
        case STACKSHOT_KCTYPE_KERN_STACKLR64 = 0x914
        case STACKSHOT_KCTYPE_USER_STACKLR = 0x915
        case STACKSHOT_KCTYPE_USER_STACKLR64 = 0x916
        case STACKSHOT_KCTYPE_NONRUNNABLE_TIDS = 0x917
        case STACKSHOT_KCTYPE_NONRUNNABLE_TASKS = 0x918
        case STACKSHOT_KCTYPE_CPU_TIMES = 0x919
        case STACKSHOT_KCTYPE_STACKSHOT_DURATION = 0x91a
        case STACKSHOT_KCTYPE_STACKSHOT_FAULT_STATS = 0x91b
        case STACKSHOT_KCTYPE_KERNELCACHE_LOADINFO = 0x91c
        case STACKSHOT_KCTYPE_THREAD_WAITINFO = 0x91d
        case STACKSHOT_KCTYPE_THREAD_GROUP_SNAPSHOT = 0x91e
        case STACKSHOT_KCTYPE_THREAD_GROUP = 0x91f
        case STACKSHOT_KCTYPE_JETSAM_COALITION_SNAPSHOT = 0x920
        case STACKSHOT_KCTYPE_JETSAM_COALITION = 0x921
        case STACKSHOT_KCTYPE_THREAD_POLICY_VERSION = 0x922
        case STACKSHOT_KCTYPE_INSTRS_CYCLES = 0x923
        case STACKSHOT_KCTYPE_USER_STACKTOP = 0x924
        case STACKSHOT_KCTYPE_ASID = 0x925
        case STACKSHOT_KCTYPE_PAGE_TABLES = 0x926
        case STACKSHOT_KCTYPE_SYS_SHAREDCACHE_LAYOUT = 0x927
        case STACKSHOT_KCTYPE_THREAD_DISPATCH_QUEUE_LABEL = 0x928
        case STACKSHOT_KCTYPE_THREAD_TURNSTILEINFO = 0x929
        case STACKSHOT_KCTYPE_TASK_CPU_ARCHITECTURE = 0x92a
        case STACKSHOT_KCTYPE_LATENCY_INFO = 0x92b
        case STACKSHOT_KCTYPE_LATENCY_INFO_TASK = 0x92c
        case STACKSHOT_KCTYPE_LATENCY_INFO_THREAD = 0x92d
        case STACKSHOT_KCTYPE_LOADINFO64_TEXT_EXEC = 0x92e
        
        case STACKSHOT_KCTYPE_TASK_DELTA_SNAPSHOT = 0x940
        case STACKSHOT_KCTYPE_THREAD_DELTA_SNAPSHOT = 0x941
        case STACKSHOT_KCTYPE_UNKNOWN_0x942 = 0x942
        case STACKSHOT_KCTYPE_UNKNOWN_0x943 = 0x943
        
        case KCDATA_TYPE_BUFFER_END = 0xF19158ED
        
        case TASK_CRASHINFO_EXTMODINFO = 0x801
        case TASK_CRASHINFO_BSDINFOWITHUNIQID = 0x802
        case TASK_CRASHINFO_TASKDYLD_INFO = 0x803
        case TASK_CRASHINFO_UUID = 0x804
        case TASK_CRASHINFO_PID = 0x805
        case TASK_CRASHINFO_PPID = 0x806
        
        case Type_0x807 = 0x807
        
        case TASK_CRASHINFO_RUSAGE_INFO = 0x808
        case TASK_CRASHINFO_PROC_NAME = 0x809
        case TASK_CRASHINFO_PROC_STARTTIME = 0x80B
        case TASK_CRASHINFO_USERSTACK = 0x80C
        case TASK_CRASHINFO_ARGSLEN = 0x80D
        case TASK_CRASHINFO_EXCEPTION_CODES = 0x80E
        case TASK_CRASHINFO_PROC_PATH = 0x80F
        case TASK_CRASHINFO_PROC_CSFLAGS = 0x810
        case TASK_CRASHINFO_PROC_STATUS = 0x811
        case TASK_CRASHINFO_UID = 0x812
        case TASK_CRASHINFO_GID = 0x813
        case TASK_CRASHINFO_PROC_ARGC = 0x814
        case TASK_CRASHINFO_PROC_FLAGS = 0x815
        case TASK_CRASHINFO_CPUTYPE = 0x816
        case TASK_CRASHINFO_WORKQUEUEINFO = 0x817
        case TASK_CRASHINFO_RESPONSIBLE_PID = 0x818
        case TASK_CRASHINFO_DIRTY_FLAGS = 0x819
        case TASK_CRASHINFO_CRASHED_THREADID = 0x81A
        case TASK_CRASHINFO_COALITION_ID = 0x81B
        case EXIT_REASON_SNAPSHOT = 0x1001
        case EXIT_REASON_USER_DESC = 0x1002
        case EXIT_REASON_USER_PAYLOAD = 0x1003
        case EXIT_REASON_CODESIGNING_INFO = 0x1004
        case EXIT_REASON_WORKLOOP_ID = 0x1005
        case EXIT_REASON_DISPATCH_QUEUE_NO = 0x1006
        case KCDATA_BUFFER_BEGIN_CRASHINFO = 0xDEADF157
        case KCDATA_BUFFER_BEGIN_DELTA_STACKSHOT = 0xDE17A59A
        case KCDATA_BUFFER_BEGIN_STACKSHOT = 0x59a25807
        case KCDATA_BUFFER_BEGIN_COMPRESSED = 0x434f4d50
        case KCDATA_BUFFER_BEGIN_OS_REASON = 0x53A20900
        case KCDATA_BUFFER_BEGIN_XNUPOST_CONFIG = 0x1E21C09F
    }
    
}

extension IInstruments.CoreProfileSessionTap {
    enum Tag: UInt32 {
        case sshot = 0x8002
        case images = 0x8004
        case kernelExtensions = 0x8005
        case config = 0x8006
        case kernel = 0x8008
        case machine = 0x8c00
        case cpuEvents = 0x8c01
        case cpuEvents2 = 0x8013
        case cpuEventsNull = 0x800e
        case rawVersion3 = 0x00001000
        case v3NullChunk = 0x00002000
        case v3Config = 0x00001b00
        case v3CpuHeaderTag = 0x00001c00
        case v3ThreadMap = 0x00001d00
        case v3RawEvents = 0x00001e00
    }
    
    struct KDHeaderV3 {
        var tag: UInt32 = 0
        var sub_tag: UInt32 = 0
        var length: UInt64 = 0
        var timebase_numer: UInt32 = 0
        var timebase_denom: UInt32 = 0
        var timestamp: UInt64 = 0
        var walltime_secs: UInt64 = 0
        var walltime_usecs: UInt32 = 0
        var timezone_minuteswest: UInt32 = 0
        var timezone_dst: UInt32 = 0
        var flags: UInt32 = 0
    }
    
    struct KDSubHeaderV3 {
        var tag: UInt32 = 0
        var major: UInt16 = 0
        var minor: UInt16 = 0
        var length: UInt64 = 0
    }
    
    struct KDCpuMapHeader {
        var version: UInt32 = 0
        var count: UInt32 = 0
    }
    
    struct KDCpuMap {
        var cpuId: UInt32 = 0
        var flags: UInt32 = 0
        var name = Data(capacity: 8)
        var args = Array<UInt32>(repeating: 0, count: 6)
    }
    
    struct KDHeaderV2 {
        var tag: UInt32 = 0
        var number_of_treads: UInt32 = 0
        var arg1: Int32 = 0
        var arg2: Int32 = 0
        var arg3: Int32 = 0
        var is_64bit: UInt32 = 0
        var tick_frequency: UInt64 = 0
    }
    
    struct KDThreadMap {
        var thread: UInt64 = 0
        var pid: UInt32 = 0
        var process = String()
    }
    
    struct KDEBUGEntry {
        var timestamp: UInt64 = 0
        var arg1: UInt64 = 0
        var arg2: UInt64 = 0
        var arg3: UInt64 = 0
        var arg4: UInt64 = 0
        var thread: UInt64 = 0
        var debug_id: UInt32 = 0
        var cpu_id: UInt32 = 0
        var unused: UInt64 = 0
        
        var event_id: UInt32 { debug_id & 0xfffffffc}
        var class_code: UInt32 { (debug_id >> 24) & 0xff }
        var subclass_code: UInt32 { (debug_id >> 16) & 0xff }
        var action_code: UInt32 { (debug_id >> 2) & 0x3fff }
        var func_code: UInt32 { debug_id & UInt32(0x00000003) }
    }
}

protocol KTEntryProtocol {
    init(_ data: Data)
}

extension IInstruments.CoreProfileSessionTap {
    struct KCData {
        let type: KT
        let size: UInt32
        let flag: UInt64
        let entry: KCTEntry
        
        init(type: KT, size: UInt32, flag: UInt64, data: Data) {
            self.type = type
            self.size = size
            self.flag = flag
            
            switch type {
                case .KCDATA_TYPE_UINT32_DESC:
                    self.entry = .UINT32_DESC(.init(data))
                    
                case .KCDATA_TYPE_UINT64_DESC:
                    self.entry = .UINT64_DESC(.init(data))
                    
                case .STACKSHOT_KCTYPE_JETSAM_LEVEL:
                    self.entry = .JETSAM_LEVEL(.init(data))
                    
                case .STACKSHOT_KCTYPE_THREAD_POLICY_VERSION:
                    self.entry = .THREAD_POLICY_VERSION(.init(data))
                    
                case .STACKSHOT_KCTYPE_KERN_PAGE_SIZE:
                    self.entry = .KERN_PAGE_SIZE(.init(data))
                    
                case .STACKSHOT_KCTYPE_OSVERSION:
                    self.entry = .OSVERSION(.init(data))
                    
                case .STACKSHOT_KCTYPE_BOOTARGS:
                    self.entry = .BOOTARGS(.init(data))
                    
                case .STACKSHOT_KCTYPE_SHAREDCACHE_LOADINFO:
                    self.entry = .SHAREDCACHE_LOADINFO(.init(data))
                
                case .KCDATA_TYPE_ARRAY_PAD0:
                    self.entry = .ARRAY_PAD0(.init(data))
                    
                default: self.entry = .INVALID
            }
        }
    }
    
    enum KCTEntry {
        case INVALID
        case UINT32_DESC(UInt32Desc)
        case UINT64_DESC(UInt64Desc)
        case JETSAM_LEVEL(JetsamLevel)
        case THREAD_POLICY_VERSION(ThreadPolicyVersion)
        case KERN_PAGE_SIZE(KernPageSize)
        case OSVERSION(OSVersion)
        case BOOTARGS(BootArgs)
        case SHAREDCACHE_LOADINFO(DYLDSharedCacheLoadInfo)
        case ARRAY_PAD0(ArrayPad0)
    }
}

extension IInstruments.CoreProfileSessionTap {
    struct UInt32Desc: KTEntryProtocol {
        var name: String = ""
        var obj: UInt32 = 0
        init(_ data: Data) {
            if data.count >= 36 {
                self.name = data.string()
                self.obj = data[32 ..< 36].withUnsafeBytes { $0.load(as: UInt32.self) }
            }
        }
    }
    
    struct UInt64Desc: KTEntryProtocol {
        var name: String = ""
        var obj: UInt64 = 0
        init(_ data: Data) {
            if data.count >= 36 {
                self.name = data.string()
                self.obj = data[32 ..< 40].withUnsafeBytes { $0.load(as: UInt64.self) }
            }
        }
    }
    
    struct JetsamLevel: KTEntryProtocol {
        var name = ""
        var obj: UInt32 = 0
        init(_ data: Data) {
            if data.count >= 4 {
                self.name = "jetsam_level"
                self.obj = data[0 ..< 4].withUnsafeBytes { $0.load(as: UInt32.self) }
            }
        }
    }
    
    struct ThreadPolicyVersion: KTEntryProtocol {
        var name = ""
        var obj: UInt32 = 0
        init(_ data: Data) {
            if data.count >= 4 {
                self.name = "thread_policy_version"
                self.obj = data[0 ..< 4].withUnsafeBytes { $0.load(as: UInt32.self) }
            }
        }
    }
    
    struct KernPageSize: KTEntryProtocol {
        var name = ""
        var obj: UInt32 = 0
        init(_ data: Data) {
            if data.count >= 4 {
                self.name = "kernel_page_size"
                self.obj = data[0 ..< 4].withUnsafeBytes { $0.load(as: UInt32.self) }
            }
        }
    }
    
    struct OSVersion: KTEntryProtocol {
        let name: String
        let obj: String
        init(_ data: Data) {
            self.name = "osversion"
            self.obj = data.string(data.count)
        }
    }
    
    struct BootArgs: KTEntryProtocol {
        let name: String
        let obj: String 
        init(_ data: Data) {
            self.name = "boot_args"
            self.obj = data.string(data.count)
        }
    }
    
    struct DYLDSharedCacheLoadInfo: KTEntryProtocol {
        var name: String = ""
        
        var imageUUID: [UInt8] = []
        var imageLoadAddress: UInt64 = 0
        var imageSlidBaseAddress: UInt64 = 0
        
        init(_ data: Data) {
            if data.count >= 32 {
                self.name = "shared_cache_dyld_load_info"
                self.imageLoadAddress = data[0 ..< 8].withUnsafeBytes { $0.load(as: UInt64.self) }
                self.imageUUID = [UInt8](data[8 ..< 24])
                self.imageSlidBaseAddress = data[24 ..< 32].withUnsafeBytes { $0.load(as: UInt64.self) }
            }
        }
    }
    
    struct ArrayPad0: KTEntryProtocol {
        var name: String = ""
        
        var imageUUID: [UInt8] = []
        var imageLoadAddress: UInt64 = 0
        var imageSlidBaseAddress: UInt64 = 0
        
        init(_ data: Data) {
            if data.count >= 32 {
                self.name = "shared_cache_dyld_load_info"
                self.imageLoadAddress = data[0 ..< 8].withUnsafeBytes { $0.load(as: UInt64.self) }
                self.imageUUID = [UInt8](data[8 ..< 24])
                self.imageSlidBaseAddress = data[24 ..< 32].withUnsafeBytes { $0.load(as: UInt64.self) }
            }
        }
    }
}


private extension Data {
    func string(_ len: Int = 32) -> String {
        var i = 0
        var cString = [UInt8]()
        while i < len, i < count, self[i] != 0 {
            cString.append(self[i])
            i += 1
        }
        cString.append(0)
        return String(cString: cString)
    }
    
}


