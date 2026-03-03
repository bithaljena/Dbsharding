# Quick Start: Heap Dump in 5 Minutes

## TL;DR - The Fastest Way

### Step 1: Start Your App (Terminal 1)
```bash
cd "/Users/bithaljena/Downloads/demo 4"
mvn clean package
java -jar target/demo-0.0.1-SNAPSHOT.jar
```

### Step 2: Get Process ID (Terminal 2)
```bash
jps -l
# Look for: 12345 com.example.demo.DemooApplication
```

### Step 3: Create Heap Dump
```bash
# Replace 12345 with your actual PID
jmap -dump:live,format=b,file=heap_dump.hprof 12345
```

### Step 4: View the File
```bash
ls -lh heap_dump.hprof
```

**Done!** Your heap dump is ready to analyze.

---

## Using the Helper Script

### Make it Executable
```bash
chmod +x heap_dump_helper.sh
```

### List Processes
```bash
./heap_dump_helper.sh list
```

### Create Dump with One Command
```bash
# Replace 12345 with your PID
./heap_dump_helper.sh dump 12345

# Create dump AND compress it
./heap_dump_helper.sh dump 12345 -z

# Save to specific directory
./heap_dump_helper.sh dump 12345 -d /tmp
```

### Analyze the Dump
```bash
./heap_dump_helper.sh analyze heap_dump.hprof
```

This will start a web server on port 7000 and open it in your browser.

---

## Common Scenarios

### Scenario 1: App is Using Too Much Memory

```bash
# Terminal 1: Start app
java -Xmx512m -jar target/demo-0.0.1-SNAPSHOT.jar

# Terminal 2: Get PID
jps -l

# Create heap dump
jmap -dump:live,format=b,file=memory_snapshot.hprof 12345

# Compress if large
gzip memory_snapshot.hprof
```

### Scenario 2: Find Memory Leak

```bash
# Take first dump at baseline
jmap -dump:live,format=b,file=baseline.hprof 12345

# Run your app for a while, make some API calls
curl -X POST http://localhost:8080/students \
  -H "Content-Type: application/json" \
  -d '{"id":1,"name":"Test","email":"test@example.com"}'

# Repeat 100 times to stress the app...

# Take second dump
jmap -dump:live,format=b,file=after_operations.hprof 12345

# Compare the two dumps in IntelliJ or Eclipse MAT
```

### Scenario 3: Production Server (Remote)

```bash
# Create dump on remote server
ssh user@production-server.com << 'EOF'
jps -l
jmap -dump:live,format=b,file=/tmp/heap.hprof <PID>
EOF

# Copy it locally
scp user@production-server.com:/tmp/heap.hprof ./heap_prod.hprof

# Analyze locally
jhat -J-Xmx2g heap_prod.hprof
```

---

## File Size Guide

| App Size | Expected Heap Dump | With Compression |
|----------|-------------------|------------------|
| Small (128MB heap) | ~80-100MB | ~20-30MB |
| Medium (512MB heap) | ~300-400MB | ~80-120MB |
| Large (2GB heap) | ~1.2-1.5GB | ~400-600MB |

**Tip:** Always use the `live` option to reduce file size:
```bash
jmap -dump:live,format=b,file=heap.hprof <PID>
```

---

## Troubleshooting Quick Fixes

| Error | Fix |
|-------|-----|
| `jmap: command not found` | `export JAVA_HOME=$(/usr/libexec/java_home)` |
| `Unable to find the process` | Make sure PID exists: `jps -l` |
| `Permission denied` | Use `sudo` or check file permissions |
| `File is too large` | Compress: `gzip heap_dump.hprof` |
| `localhost:7000 won't open` | Check if jhat is still running: `ps aux \| grep jhat` |

---

## Best Tools for Analysis

**IntelliJ IDEA** (Best for Development)
- Already integrated
- User-friendly UI
- Real-time analysis
- Just open the .hprof file: File → Open → heap_dump.hprof

**Eclipse Memory Analyzer** (Best for Production)
- Standalone tool
- Detailed leak detection
- Great visualizations
- Download: https://www.eclipse.org/mat/

**jhat** (Built-in, Command Line)
- No installation needed
- Web-based interface
- Run: `jhat -J-Xmx2g heap_dump.hprof`
- Open: http://localhost:7000

---

## One-Liner Commands

```bash
# List processes
jps -l

# Create dump
jmap -dump:live,format=b,file=heap.hprof $(jps -l | grep DemooApplication | awk '{print $1}')

# Compress
gzip -v heap.hprof

# Analyze
jhat -J-Xmx2g heap.hprof

# Find largest objects
# (In jhat web UI: OQL → enter query)
select * from java.util.ArrayList a where a.size > 100

# Copy to another machine
scp heap.hprof.gz user@remote:/path/to/backup

# Clean up old dumps
find . -name "*.hprof" -mtime +7 -delete
```

---

## Reference: Common JVM Flags

When starting your Spring Boot app for memory analysis:

```bash
# Enable JMX monitoring
java -Dcom.sun.management.jmxremote \
     -Dcom.sun.management.jmxremote.port=9999 \
     -jar app.jar

# Set specific heap size (for testing)
java -Xms256m -Xmx512m \
     -jar app.jar

# Enable Java Flight Recorder
java -XX:StartFlightRecording=filename=recording.jfr \
     -jar app.jar

# Verbose GC logging (shows memory events)
java -Xloggc:gc.log -XX:+PrintGCDetails \
     -jar app.jar

# All together (full diagnostics)
java -Xms256m -Xmx512m \
     -XX:StartFlightRecording=filename=recording.jfr \
     -Xloggc:gc.log -XX:+PrintGCDetails \
     -Dcom.sun.management.jmxremote \
     -jar app.jar
```

---

## What to Look For in a Heap Dump

✅ **Good Signs:**
- Most objects are small (<1MB each)
- No single class has millions of instances
- Collections have reasonable sizes
- String instances are not excessive

❌ **Red Flags (Potential Leaks):**
- Millions of instances of the same class
- Collections growing indefinitely
- Unclosed resources (Streams, Connections)
- Static collections with unexpected data
- Circular references that should be garbage collected

---

## Next Steps

1. **Read the full guide:** `HEAP_DUMP_GUIDE.md` in your project
2. **Try the helper script:** `./heap_dump_helper.sh list`
3. **Analyze your first dump:** `jmap -dump:live,format=b,file=first_dump.hprof <PID>`
4. **Download Eclipse MAT** for advanced analysis
5. **Join the conversation:** Check Spring Boot or Java memory profiling discussions online

Happy debugging! 🚀
