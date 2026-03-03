# Java Heap Dump Guide - Step by Step Process

## Table of Contents
1. [What is a Heap Dump?](#what-is-a-heap-dump)
2. [Method 1: Using jmap (Simplest)](#method-1-using-jmap)
3. [Method 2: Using jcmd](#method-2-using-jcmd)
4. [Method 3: Using Java Flight Recorder (JFR)](#method-3-using-java-flight-recorder)
5. [Method 4: Using IntelliJ IDEA](#method-4-using-intellij-idea)
6. [Analyzing the Heap Dump](#analyzing-the-heap-dump)
7. [Finding Memory Leaks](#finding-memory-leaks)
8. [Troubleshooting](#troubleshooting)

---

## What is a Heap Dump?

### Definition
A **heap dump** is a snapshot of all objects in the Java heap memory at a specific point in time. It contains:
- All active object instances
- Object reference relationships
- Memory size occupied by each object
- Stack traces and thread information

### Why Use Heap Dumps?
- **Find Memory Leaks**: Identify objects that should be garbage collected but aren't
- **Analyze Memory Usage**: Understand which objects consume the most memory
- **Debug Performance Issues**: Track object allocation patterns
- **Production Issues**: Capture memory state without stopping the application

### Heap Dump File Formats
- **HPROF** (default): Binary format used by jmap, smaller file size
- **PHD**: IBM's format
- **Full dump vs. Partial**: Full dumps contain all objects; partial are more lightweight

---

## Method 1: Using jmap (Simplest)

**Best for**: Quick heap dumps, simple commands

### Step 1: Start Your Spring Boot Application

```bash
cd "/Users/bithaljena/Downloads/demo 4"
mvn clean package
java -jar target/demo-0.0.1-SNAPSHOT.jar
```

Keep this running in one terminal.

### Step 2: Find the Java Process ID (PID)

In a new terminal window, list all Java processes:

```bash
jps -l
```

**Output example:**
```
12345 com.example.demo.DemooApplication
67890 org.apache.catalina.startup.Bootstrap
```

Note the PID of your DemooApplication (e.g., `12345`)

**Alternative method** - if jps doesn't work:
```bash
ps aux | grep java
```

### Step 3: Capture the Heap Dump

Use jmap with the PID from Step 2:

```bash
jmap -dump:live,format=b,file=heap_dump.hprof 12345
```

**Parameters explained:**
- `-dump` : Create a heap dump
- `live` : Only dump live objects (exclude garbage)
- `format=b` : Binary format (HPROF)
- `file=heap_dump.hprof` : Output filename
- `12345` : Your Java process ID

**Expected output:**
```
Dumping heap to heap_dump.hprof ...
Heap dump file created
```

### Step 4: Locate Your Heap Dump

The file will be created in your current directory:

```bash
ls -lh heap_dump.hprof
```

You can also specify a different location:

```bash
jmap -dump:live,format=b,file=/tmp/my_heap_dump.hprof 12345
```

---

## Method 2: Using jcmd

**Best for**: Java 9+, more reliable, doesn't require separate tools

### Step 1: List All Java Processes

```bash
jcmd -l
```

**Output:**
```
12345 com.example.demo.DemooApplication
67890 /path/to/another/java/process
```

### Step 2: Capture Heap Dump with jcmd

```bash
jcmd 12345 GC.heap_dump /tmp/heap_dump_jcmd.hprof
```

**Parameters:**
- `12345` : Process ID
- `GC.heap_dump` : The command to execute
- `/tmp/heap_dump_jcmd.hprof` : Output file path

**Expected output:**
```
Heap dump file created
```

### Step 3: Verify the Dump

```bash
ls -lh /tmp/heap_dump_jcmd.hprof
file /tmp/heap_dump_jcmd.hprof
```

---

## Method 3: Using Java Flight Recorder

**Best for**: Production environments, detailed profiling data

### Step 1: Start Your Application with JFR Enabled

**Option A: Using Command Line Flags**

```bash
java -XX:StartFlightRecording=filename=demo_recording.jfr,dumponexit=true,settings=default \
     -jar target/demo-0.0.1-SNAPSHOT.jar
```

**Parameters:**
- `StartFlightRecording` : Enable JFR
- `filename=demo_recording.jfr` : Output file name
- `dumponexit=true` : Save recording when app exits
- `settings=default` : Use default profiling settings

**Option B: Using application.properties**

Add to `/src/main/resources/application.properties`:

```properties
spring.application.name=demoo
# ...existing properties...

# JFR Configuration (Java 11+)
jdk.jfr.enabled=true
```

### Step 2: Run Your Application

```bash
cd "/Users/bithalja/Downloads/demo 4"
java -XX:StartFlightRecording=filename=flight_recording.jfr \
     -jar target/demo-0.0.1-SNAPSHOT.jar
```

### Step 3: Interact with Your Application

Make some API calls to generate activity:

```bash
# In another terminal
curl -X POST http://localhost:8080/students \
  -H "Content-Type: application/json" \
  -d '{"id":1,"name":"John Doe","email":"john@example.com"}'

curl http://localhost:8080/students/1
```

### Step 4: Stop the Application

Press `Ctrl+C` in the application terminal. This will dump the JFR recording to the file.

### Step 5: Verify the Recording

```bash
ls -lh flight_recording.jfr
```

---

## Method 4: Using IntelliJ IDEA

**Best for**: Development, IDE integration, real-time analysis

### Step 1: Configure IntelliJ IDEA

1. Open **Preferences** → **Tools** → **Debugger** → **Profiler**
2. Ensure "Debug symbols" is checked
3. Set heap dump location (optional)

### Step 2: Run Your Application in IntelliJ

1. Click **Run** → **Run 'DemooApplication'** (or press `Ctrl+R`)
2. Wait for "Started DemooApplication" message in the console

### Step 3: Open the Profiler

1. In the bottom toolbar, find **Profiler** (or click **Run** → **Open Profiler Tool Window**)
2. You'll see CPU, Memory, and Network tabs

### Step 4: Force Garbage Collection & Capture Heap

1. Click on the **Memory** tab
2. Press the garbage collection icon (trash can icon)
3. Right-click on the heap area and select **Dump Java Heap**
   OR
   Click the **Dump Heap** button

### Step 5: Select Location

IntelliJ will prompt you to choose a location. Select Desktop or Downloads for easy access.

### Step 6: View the Dump

IntelliJ will automatically open the heap dump analysis with:
- Objects by class
- Memory breakdown
- Instance counts
- Reference chains

---

## Analyzing the Heap Dump

### Using IntelliJ IDEA (Built-in Analyzer)

1. **Open the heap dump file:**
   - **File** → **Open** → Select `.hprof` file
   - IntelliJ automatically analyzes it

2. **View Key Metrics:**
   - **Classes** tab: Shows all classes and instances
   - **Dominators** tab: Shows memory hogs
   - **Inspector** tab: Drill down into specific objects

3. **Find Large Objects:**
   ```
   Classes → Sort by "Shallow Size" (descending)
   ```

### Using Eclipse Memory Analyzer Tool (MAT)

**Download:** https://www.eclipse.org/mat/downloads.php

#### Step 1: Open Heap Dump in MAT

1. Launch Eclipse Memory Analyzer
2. **File** → **Open Heap Dump**
3. Select your `.hprof` file
4. Choose parser (keep default)

#### Step 2: Generate Report

MAT will show:
- **Leak Suspects** report
- **Top Components** consuming memory
- **Histogram** of objects by class

#### Step 3: Analyze Results

- **Dominator Tree**: Shows object hierarchy and memory impact
- **Leak Suspects**: Identifies likely memory leaks
- **Histogram**: Counts instances of each class

### Using Command Line Tools

**View heap dump info:**
```bash
jhat -J-Xmx2g heap_dump.hprof
```

Opens an HTTP server (port 7000) with analysis interface:
```
http://localhost:7000
```

---

## Finding Memory Leaks

### Common Leak Patterns

#### 1. Static Collections Growing Indefinitely

```java
// Example of a memory leak
public class CacheManager {
    private static List<Object> cache = new ArrayList<>();
    
    public void addToCache(Object obj) {
        cache.add(obj);  // Never removes! Leaks memory
    }
}
```

**How to find in heap dump:**
1. Search for the class name in heap dump analyzer
2. Check instance count over time
3. Look for collections with unexpectedly large sizes

#### 2. Unclosed Resources

```java
// Memory leak example
FileInputStream fis = new FileInputStream("file.txt");
// Never closed - leaks file handles and memory
```

**Investigation steps:**
1. Search for Stream classes in heap dump
2. Look for unclosed resources (BufferedInputStream, FileInputStream, etc.)
3. Check for Connection objects not closed

#### 3. Event Listeners Not Removed

```java
// Memory leak
button.addListener(listener);  // Never removed!
```

**How to identify:**
1. Check listener collections in components
2. Verify listener count is reasonable
3. Look for orphaned references

### Heap Dump Analysis Steps for Finding Leaks

```
1. Take initial heap dump (baseline)
2. Perform suspected leaking operation multiple times
3. Take second heap dump
4. Compare the two dumps in analyzer
5. Look for classes with significantly increased instance count
6. Trace references to find what's holding the objects
```

---

## Troubleshooting

### Issue 1: "jmap: command not found"

**Solution:** Ensure JAVA_HOME is set correctly:

```bash
echo $JAVA_HOME
# Should output something like: /Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home

# If empty, set it:
export JAVA_HOME=$(/usr/libexec/java_home)
echo $JAVA_HOME
```

### Issue 2: "Could not open `...`: Permission denied"

**Solution:** Run with sudo if necessary:

```bash
sudo jmap -dump:live,format=b,file=heap_dump.hprof 12345
```

### Issue 3: Heap Dump File is Too Large

**Solution:** Only dump live objects and specify a different location with more disk space:

```bash
jmap -dump:live,format=b,file=/tmp/heap_dump.hprof 12345
```

Or use compression:
```bash
gzip heap_dump.hprof
```

### Issue 4: Process ID Not Found

**Make sure your application is still running:**

```bash
jps -l  # List all Java processes
ps aux | grep DemooApplication
```

### Issue 5: "Unable to open socket file"

**Solution:** The application might not be JVM-instrumented. Restart with JMX enabled:

```bash
java -Dcom.sun.management.jmxremote=true \
     -jar target/demo-0.0.1-SNAPSHOT.jar
```

---

## Quick Reference Commands

```bash
# Find Java processes
jps -l
ps aux | grep java

# Method 1: jmap (simplest)
jmap -dump:live,format=b,file=heap.hprof <PID>

# Method 2: jcmd (Java 9+)
jcmd <PID> GC.heap_dump /path/to/heap.hprof

# Method 3: Java Flight Recorder
java -XX:StartFlightRecording=filename=recording.jfr -jar app.jar

# Method 4: Check file size
ls -lh heap_dump.hprof

# Compress if too large
gzip heap_dump.hprof

# Copy to another machine (if needed)
scp heap_dump.hprof user@remote:/path/to/destination
```

---

## Best Practices

✅ **DO:**
- Take heap dumps during normal operation to get baseline
- Compare multiple dumps over time to identify trends
- Use `live` option in jmap to exclude garbage
- Document when heap dumps were taken and under what conditions
- Keep heap dumps secure (contain sensitive object data)

❌ **DON'T:**
- Take heap dumps too frequently (impacts performance)
- Share heap dumps without checking for sensitive data
- Analyze production heap dumps on systems without security measures
- Ignore small heap dump differences in development

---

## Additional Resources

- [Oracle JMap Documentation](https://docs.oracle.com/en/java/javase/17/docs/specs/man/jmap.html)
- [Eclipse Memory Analyzer](https://www.eclipse.org/mat/)
- [Java Flight Recorder User Guide](https://docs.oracle.com/en/java/javase/17/jfapi/introduction.html)
- [IntelliJ IDEA Profiler](https://www.jetbrains.com/help/idea/profiler-ui.html)
