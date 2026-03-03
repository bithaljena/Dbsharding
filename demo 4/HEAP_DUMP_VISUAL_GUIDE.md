# Heap Dump Process Flow Chart

## Decision Tree: Which Method to Use?

```
                          Need a Heap Dump?
                                  |
                    ______________|______________
                   |                            |
            Running on macOS            Production Server
                   |                            |
         __________|_____________      ________|________
        |                       |     |                 |
    Simple?            Want IDE         Remote SSH      
        |              Integration?    Connection?
    YES|NO                 |                |
    |  |              YES  |      NO    YES |     NO
    |  |               |   |          |     |      |
    |  ├─ jmap ────────┴─ IntelliJ    | Local App  |
    |  |  (fastest)       (IDE)       |     |      |
    |  |                              |  jmap      jcmd
    |  |                         ssh + jmap   (Java 9+)
    |  |
    |  └─ jcmd
    |     (Java 9+)
    |
    └─ For Production Profiling
       Use Java Flight Recorder

```

## Timeline: Step by Step (Simplified)

```
┌─────────────────────────────────────────────────────────────────┐
│ HEAP DUMP PROCESS TIMELINE                                      │
└─────────────────────────────────────────────────────────────────┘

T0: Preparation
├─ Start Spring Boot app (Terminal 1)
└─ Note the PID from jps output

T1: Capture (2-5 seconds depending on heap size)
├─ Run: jmap -dump:live,format=b,file=heap.hprof <PID>
└─ File created

T2: Verification (instant)
└─ Check file: ls -lh heap.hprof

T3: Analysis (seconds to minutes depending on file size)
├─ Option 1: Open in IntelliJ IDEA (File → Open)
├─ Option 2: Use Eclipse MAT
└─ Option 3: jhat -J-Xmx2g heap.hprof

T4: Interpretation
└─ Review classes, objects, memory usage

T5: Action
└─ Identify leaks, fix code, prevent regression
```

## Method Comparison Matrix

```
┌──────────────────┬──────────────┬────────────┬──────────┬─────────────┐
│ Feature          │ jmap         │ jcmd       │ JFR      │ IntelliJ    │
├──────────────────┼──────────────┼────────────┼──────────┼─────────────┤
│ Ease of Use      │ ⭐⭐⭐⭐⭐  │ ⭐⭐⭐⭐   │ ⭐⭐⭐   │ ⭐⭐⭐⭐⭐  │
│ Setup Required   │ None         │ None       │ Flags    │ IDE Open    │
│ Works on Java 8  │ Yes          │ No         │ No       │ Yes         │
│ Works on Java 9+ │ Yes          │ Yes        │ Yes      │ Yes         │
│ macOS            │ Yes          │ Yes        │ Yes      │ Yes         │
│ Linux            │ Yes          │ Yes        │ Yes      │ Yes         │
│ Windows          │ Yes          │ Yes        │ Yes      │ Yes         │
│ Production Ready │ ⭐⭐⭐⭐   │ ⭐⭐⭐⭐⭐  │ ⭐⭐⭐⭐⭐  │ ⭐⭐⭐      │
│ File Size        │ Medium       │ Medium     │ Large    │ Medium      │
│ Analysis Tools   │ Many         │ Many       │ JFR Tool │ Built-in    │
│ Learning Curve   │ Shallow      │ Shallow    │ Moderate │ Shallow     │
└──────────────────┴──────────────┴────────────┴──────────┴─────────────┘

Legend: ⭐ = Rating (1-5 stars)
```

## Memory Leak Detection Flow

```
┌──────────────────────────────────────────────────────────┐
│ MEMORY LEAK DETECTION WORKFLOW                           │
└──────────────────────────────────────────────────────────┘

STEP 1: Baseline
┌────────────────────────────────┐
│ Take heap dump at app startup  │
│ when memory is normal          │
│ (file: baseline.hprof)         │
└────────────────────────────────┘
                 │
                 ▼
STEP 2: Operation
┌────────────────────────────────┐
│ Run the suspected operation    │
│ multiple times (100x or more)  │
│ to trigger the leak            │
│ (make API calls, process data) │
└────────────────────────────────┘
                 │
                 ▼
STEP 3: Snapshot
┌────────────────────────────────┐
│ Take second heap dump          │
│ while app is still running     │
│ (file: after.hprof)            │
└────────────────────────────────┘
                 │
                 ▼
STEP 4: Compare
┌────────────────────────────────┐
│ Load both dumps in analyzer    │
│ Compare class instance counts  │
│ Look for growth patterns       │
│ (IntelliJ or Eclipse MAT)      │
└────────────────────────────────┘
                 │
                 ▼
STEP 5: Identify
┌────────────────────────────────┐
│ Find classes with significant  │
│ instance count increase        │
│ (millions instead of hundreds) │
└────────────────────────────────┘
                 │
                 ▼
STEP 6: Trace
┌────────────────────────────────┐
│ Use reference chain analysis   │
│ to find what's holding refs    │
│ (GC roots → your object)       │
└────────────────────────────────┘
                 │
                 ▼
STEP 7: Fix
┌────────────────────────────────┐
│ Review code that maintains     │
│ references to the objects      │
│ Add cleanup/removal logic      │
└────────────────────────────────┘
                 │
                 ▼
STEP 8: Verify
┌────────────────────────────────┐
│ Repeat steps 1-5 with fixed    │
│ code to confirm leak is gone   │
└────────────────────────────────┘
```

## File Size Impact

```
Heap Dump File Sizes Over Time (Example: Growing Memory)

Heap Used: ████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 25% (256 MB)
Dump Size: ████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ~200 MB

Heap Used: ████████████████░░░░░░░░░░░░░░░░░░░░░░░░░ 40% (400 MB)
Dump Size: ████████████████░░░░░░░░░░░░░░░░░░░░░░░░░ ~300 MB

Heap Used: ████████████████████████░░░░░░░░░░░░░░░░░ 60% (600 MB)
Dump Size: ████████████████████████░░░░░░░░░░░░░░░░░ ~450 MB

                    ⚠️ POTENTIAL MEMORY LEAK
                    (constantly growing)
```

## Quick Command Reference

```bash
═══════════════════════════════════════════════════════════════
  HEAP DUMP QUICK REFERENCE
═══════════════════════════════════════════════════════════════

1️⃣  LIST PROCESSES
   $ jps -l
   Output: 12345 com.example.demo.DemooApplication

2️⃣  CREATE DUMP (jmap - simplest)
   $ jmap -dump:live,format=b,file=heap.hprof 12345
   Creates: heap.hprof (~100-500 MB typical)

3️⃣  CREATE DUMP (jcmd - modern)
   $ jcmd 12345 GC.heap_dump heap.hprof
   Creates: heap.hprof (~100-500 MB typical)

4️⃣  COMPRESS IF LARGE
   $ gzip heap.hprof
   Reduces size by 60-80%

5️⃣  ANALYZE WITH BUILTIN TOOL
   $ jhat -J-Xmx2g heap.hprof
   Opens: http://localhost:7000

6️⃣  OR: ANALYZE IN IDE
   File → Open → heap.hprof (IntelliJ does this automatically)

═══════════════════════════════════════════════════════════════
```

## Common Problem Diagnosis

```
                        Memory Issues?
                              │
                  ____________│____________
                 │                        │
            Heap Size      Out of Memory Errors
            Growing?       After restart
                 │                        │
            YES  │  NO            Takes time to recur?
                 │  │                     │
                 │  │                YES  │  NO
                 │  │                 │   │   │
         LEAK    │  │            Leak    │   │
        LIKELY   │  │           LIKELY  │   │
                 │  │                    │   │
    ┌────────────┘  │            ┌──────┘   │
    │               │            │          │
 Dump #1        Dump #2      Check:    Check:
 Early          After Ops    • GC      • Spikes
 Small          Larger?      • Cache   • Sessions
                 │            │        │
                 │       Maybe not     │
                 │       a leak        │
                 │                     │
    └──────────────┬──────────────────┘
                   │
          Compare dumps in
          IntelliJ or MAT
                   │
          Find differing classes
          with high instance count
                   │
          Use reference analyzer
          to trace to root cause
```

## Tools Availability Check

```bash
# Run this to see what's available on your system:

echo "=== Java Tools Check ==="
which java        && echo "✓ Java installed" || echo "✗ Java not found"
which jps         && echo "✓ jps available" || echo "✗ jps not found"
which jmap        && echo "✓ jmap available" || echo "✗ jmap not found"
which jcmd        && echo "✓ jcmd available" || echo "✗ jcmd not found"
which jhat        && echo "✓ jhat available" || echo "✗ jhat not found"

echo ""
echo "=== Java Version ==="
java -version

echo ""
echo "=== JAVA_HOME Check ==="
echo "JAVA_HOME: $JAVA_HOME"
```

## When to Use Each Tool

```
START: Need to analyze memory?
  │
  ├─ QUICK & LOCAL?
  │  └─ IntelliJ IDEA (open File → heap_dump.hprof)
  │     ✓ Fastest for developers
  │     ✓ Built-in analysis
  │     ✓ Beautiful UI
  │
  ├─ COMMAND LINE?
  │  ├─ Java 8?
  │  │  └─ Use: jmap
  │  │
  │  └─ Java 9+?
  │     ├─ New to this?
  │     │  └─ Use: jmap (same commands work)
  │     │
  │     └─ Production?
  │        └─ Use: jcmd (more reliable)
  │
  ├─ DETAILED ANALYSIS?
  │  └─ Eclipse MAT
  │     ✓ Leak detection
  │     ✓ Detailed reports
  │     ✓ Stand-alone tool
  │
  └─ PRODUCTION PROFILING?
     └─ Java Flight Recorder
        ✓ Minimal overhead
        ✓ Complete system profile
        ✓ Thread & lock info
```

## Next: After Getting the Dump

```
heap_dump.hprof (you have this now)
         │
         ├─ Step 1: Verify file
         │  └─ ls -lh heap_dump.hprof
         │
         ├─ Step 2: Choose tool
         │  ├─ Option A: IntelliJ → File → Open
         │  ├─ Option B: Eclipse MAT → Open Heap Dump
         │  └─ Option C: jhat http://localhost:7000
         │
         ├─ Step 3: Analyze
         │  ├─ Look at "Classes" tab
         │  ├─ Sort by "Shallow Size"
         │  └─ Find the largest consumers
         │
         └─ Step 4: Investigate
            ├─ Check instance counts
            ├─ Review reference chains
            └─ Identify possible leaks
```

---

This visual guide complements the detailed guides (HEAP_DUMP_GUIDE.md) and quick start (HEAP_DUMP_QUICK_START.md).
