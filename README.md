# itis

A small library for asking questions about types.

```zig
/// Example serialize function that uses `itis` to serialize ArrayList and ArrayHashMap.
pub fn serialize(writer: anytype, value: anytype) !void {
    const T = @TypeOf(value);
    if (itis.anArrayList(T)) {
        try writer.writeAll("[");
        for (value.items) |item, i| {
            if (i != 0)
                try writer.writeAll(",");
            try serialize(writer, item);
        }
        return writer.writeAll("]");
    }
    if (itis.anArrayHashMap(T)) {
        try writer.writeAll("{");
        for (value.keys()) |key, i| {
            const v = value.values()[i];
            if (i != 0)
                try writer.writeAll(",");

            try serialize(writer, key);
            try writer.writeAll(":");
            try serialize(writer, v);
        }
        return writer.writeAll("}");
    }

    // The rest is left as an execise for the reader
}
```
