# Heap Dump Learning Resources - Complete Guide

Welcome! I've created a comprehensive set of resources to help you take and analyze heap dumps for your Spring Boot application. Here's what's available:

## 📚 Documentation Files

### 1. **HEAP_DUMP_QUICK_START.md** ⭐ START HERE
The fastest way to get a heap dump in 5 minutes.

**Contents:**
- TL;DR quick steps
- Using the helper script
- Common scenarios (memory leaks, production servers, large files)
- Troubleshooting quick fixes
- One-liner commands
- Best tools for analysis
- Common JVM flags reference

**Best for:** Getting your first heap dump quickly without reading everything.

---

### 2. **HEAP_DUMP_GUIDE.md** 📖 COMPREHENSIVE REFERENCE
Complete step-by-step guide covering all methods.

**Includes:**
- What heap dumps are and why to use them
- **Method 1: jmap** (simplest)
- **Method 2: jcmd** (modern, Java 9+)
- **Method 3: Java Flight Recorder** (production profiling)
- **Method 4: IntelliJ IDEA** (IDE integration)
- How to analyze with multiple tools (IntelliJ, Eclipse MAT, jhat)
- Finding memory leaks (patterns, investigation steps)
- Detailed troubleshooting guide
- Best practices and security considerations

**Best for:** Understanding every detail, production environments, finding memory leaks.

---

### 3. **HEAP_DUMP_VISUAL_GUIDE.md** 📊 FLOWCHARTS & DIAGRAMS
Visual reference with decision trees, comparisons, and flowcharts.

**Contains:**
- Decision tree: which method to use
- Timeline visualization
- Method comparison matrix
- Memory leak detection workflow
- File size impact visualization
- Tools availability checker
- Common problem diagnosis flowchart
- When to use each tool

**Best for:** Visual learners, quick decision-making, understanding relationships.

---

## 🛠️ Automation & Tools

### **heap_dump_helper.sh** - Bash Automation Script
Make the entire process automated with helpful commands.

**Features:**
- List running Java processes
- Create heap dumps with jmap
- Create heap dumps with jcmd
- Analyze dumps with jhat
- Compress large files
- Colored output for readability

**Usage Examples:**
```bash
# Make it executable (one time)
chmod +x heap_dump_helper.sh

# List Java processes
./heap_dump_helper.sh list

# Create dump (simplest)
./heap_dump_helper.sh dump 12345

# Create dump and compress automatically
./heap_dump_helper.sh dump 12345 -z

# Analyze the dump
./heap_dump_helper.sh analyze heap_dump.hprof
```

---

## 🎯 Quick Reference

### Method 1: Simplest (jmap)
```bash
# List processes
jps -l

# Create dump (replace 12345 with your PID)
jmap -dump:live,format=b,file=heap.hprof 12345

# Verify
ls -lh heap.hprof
```

### Method 2: Modern (jcmd - Java 9+)
```bash
# List processes
jcmd -l

# Create dump
jcmd 12345 GC.heap_dump /path/to/heap.hprof
```

### Method 3: Production (Java Flight Recorder)
```bash
java -XX:StartFlightRecording=filename=recording.jfr \
     -jar target/demo-0.0.1-SNAPSHOT.jar
```

### Method 4: IDE (IntelliJ IDEA)
1. Run app in IntelliJ
2. Bottom toolbar → Profiler tab
3. Memory tab → Garbage Collection icon → Dump Heap
4. View analysis automatically

---

## 📋 File Size Reference

| Heap Size | Dump Size | Compressed |
|-----------|-----------|-----------|
| 128 MB | 80-100 MB | 20-30 MB |
| 512 MB | 300-400 MB | 80-120 MB |
| 2 GB | 1.2-1.5 GB | 400-600 MB |

**Tip:** Always use `live` option to reduce size by ~30%

---

## 🔍 Memory Leak Detection Process

```
1. Take baseline heap dump at startup
2. Run suspected leaking operation 100+ times
3. Take second heap dump
4. Compare in analyzer (IntelliJ or Eclipse MAT)
5. Look for classes with millions of instances
6. Trace references to find the root cause
7. Fix the code
8. Verify with another dump run
```

---

## 🛠️ Analysis Tools

### IntelliJ IDEA (Best for Development)
- Built-in heap dump analyzer
- Open .hprof file: File → Open
- Automatic analysis and visualization
- Dominators, Classes, Inspector tabs

### Eclipse Memory Analyzer (Best for Production)
- Standalone tool
- Download: https://www.eclipse.org/mat/
- Leak detection reports
- Detailed visualizations

### jhat (Command Line)
- Built-in with Java
- Run: `jhat -J-Xmx2g heap.hprof`
- Access: http://localhost:7000

---

## 🚀 Your Spring Boot Application

Your app is configured with:
- Spring Boot 4.0.3
- Java 17
- H2 in-memory database
- Spring Data JPA
- REST controller endpoints

**To test with API calls:**
```bash
# POST a student
curl -X POST http://localhost:8080/students \
  -H "Content-Type: application/json" \
  -d '{"id":1,"name":"John Doe","email":"john@example.com"}'

# GET a student
curl http://localhost:8080/students/1
```

---

## 📝 Common Scenarios

### Scenario 1: App Using Too Much Memory
```bash
java -Xmx512m -jar target/demo-0.0.1-SNAPSHOT.jar
jps -l                              # Get PID
jmap -dump:live,format=b,file=heap.hprof 12345
# Analyze the dump
```

### Scenario 2: Find Memory Leak
```bash
# Baseline
jmap -dump:live,format=b,file=baseline.hprof 12345

# Run operations
for i in {1..100}; do curl -X POST http://localhost:8080/students ...; done

# After operations
jmap -dump:live,format=b,file=after.hprof 12345

# Compare baseline.hprof vs after.hprof in analyzer
```

### Scenario 3: Production Server
```bash
# Remote: create dump
ssh user@server.com "jmap -dump:live,format=b,file=/tmp/heap.hprof PID"

# Copy locally
scp user@server.com:/tmp/heap.hprof ./heap_prod.hprof

# Analyze
jhat -J-Xmx2g heap_prod.hprof
```

---

## ⚠️ Common Issues & Solutions

| Problem | Solution |
|---------|----------|
| `jmap: command not found` | `export JAVA_HOME=$(/usr/libexec/java_home)` |
| Process not found | Verify: `jps -l` |
| Permission denied | Use `sudo` or check permissions |
| File too large | Add `live` option or compress: `gzip heap.hprof` |
| jhat won't start | Ensure enough RAM: `jhat -J-Xmx2g ...` |
| IntelliJ won't open | Check file format is .hprof |

---

## 🎓 Learning Path

### Beginner (5 minutes)
1. Read: HEAP_DUMP_QUICK_START.md
2. Do: Run `./heap_dump_helper.sh list`
3. Do: Create your first dump with jmap
4. Do: Open in IntelliJ (File → Open)

### Intermediate (30 minutes)
1. Read: HEAP_DUMP_GUIDE.md (Methods 1-2)
2. Do: Try all 4 methods
3. Do: Create dumps with different tools
4. Do: Compare file sizes and speeds

### Advanced (1-2 hours)
1. Read: Full HEAP_DUMP_GUIDE.md
2. Read: HEAP_DUMP_VISUAL_GUIDE.md
3. Do: Intentionally create a memory leak
4. Do: Use techniques to find and fix it
5. Do: Download Eclipse MAT and compare with IntelliJ

---

## 💡 Pro Tips

✅ **Always:**
- Take baseline dump at startup
- Use `live` option in jmap
- Document when dumps were taken
- Compare dumps over time
- Keep dumps secure (contains object data)

❌ **Never:**
- Take dumps every second (impacts performance)
- Share dumps publicly without review
- Ignore small differences in development
- Forget to clean up old dumps

---

## 📚 External Resources

- [Oracle jmap Documentation](https://docs.oracle.com/en/java/javase/17/docs/specs/man/jmap.html)
- [Eclipse Memory Analyzer](https://www.eclipse.org/mat/)
- [Java Flight Recorder](https://docs.oracle.com/en/java/javase/17/jfapi/introduction.html)
- [IntelliJ IDEA Profiler](https://www.jetbrains.com/help/idea/profiler-ui.html)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)

---

## 🆘 Quick Help

**Q: Which method should I use?**
A: Start with jmap (simplest). Use IntelliJ if you're in the IDE. Use jcmd for production.

**Q: How big will the dump be?**
A: Usually 30-50% of heap size. Check: `ls -lh heap.hprof`

**Q: Can I compress it?**
A: Yes! Use `gzip heap.hprof` - saves 60-80% space.

**Q: Where can I analyze it?**
A: IntelliJ (easiest), Eclipse MAT (detailed), or jhat (command line).

**Q: Is it safe to take dumps in production?**
A: Yes, takes seconds. Use jcmd (most reliable for production).

**Q: How often should I take dumps?**
A: For baseline: once at startup. For leak detection: before and after operations.

---

## 📞 Getting Help

All four documents are complementary:
- **Start with:** HEAP_DUMP_QUICK_START.md
- **Go deeper:** HEAP_DUMP_GUIDE.md
- **Visual help:** HEAP_DUMP_VISUAL_GUIDE.md
- **Automate:** heap_dump_helper.sh

---

## Version Info

Created for:
- **Java 17**
- **Spring Boot 4.0.3**
- **macOS with zsh**
- **IntelliJ IDEA**

All tools work on Java 8+, Linux, macOS, Windows (with PowerShell instead of bash for script).

---

**Ready to start? Open HEAP_DUMP_QUICK_START.md and follow the 5-minute process!** 🚀
