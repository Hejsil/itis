const std = @import("std");

const itis = @This();

/// Returns `true` if `T` is a type created from the `std.ArrayList` family of functions.
/// This includes both Managed and Unmanaged versions.
pub fn anArrayList(comptime T: type) bool {
    return anArrayListManaged(T) or anArrayListUnmanaged(T);
}

test "itis.anArrayList" {
    try std.testing.expect(!itis.anArrayList(u8));
    try std.testing.expect(!itis.anArrayList([20]u8));
    try std.testing.expect(itis.anArrayList(std.ArrayList(u8)));
    try std.testing.expect(itis.anArrayList(std.ArrayListUnmanaged(u8)));
}

/// Returns `true` if `T` is a type created from the Managed versions of the `std.ArrayList`
/// family of functions.
pub fn anArrayListManaged(comptime T: type) bool {
    const info = ArrayListInfo.get(T) orelse return false;

    return T == std.ArrayListAligned(info.Child, null) or
        T == std.ArrayListAligned(info.Child, info.alignment);
}

test "itis.anArrayListManaged" {
    try std.testing.expect(!itis.anArrayListManaged(u8));
    try std.testing.expect(!itis.anArrayListManaged([20]u8));
    try std.testing.expect(itis.anArrayListManaged(std.ArrayList(u8)));
    try std.testing.expect(!itis.anArrayListManaged(std.ArrayListUnmanaged(u8)));
}

/// Returns `true` if `T` is a type created from the Unmanaged versions of the `std.ArrayList`
/// family of functions.
pub fn anArrayListUnmanaged(comptime T: type) bool {
    const info = ArrayListInfo.get(T) orelse return false;

    return T == std.ArrayListAlignedUnmanaged(info.Child, null) or
        T == std.ArrayListAlignedUnmanaged(info.Child, info.alignment);
}

test "itis.anArrayListUnmanaged" {
    try std.testing.expect(!itis.anArrayListUnmanaged(u8));
    try std.testing.expect(!itis.anArrayListUnmanaged([20]u8));
    try std.testing.expect(!itis.anArrayListUnmanaged(std.ArrayList(u8)));
    try std.testing.expect(itis.anArrayListUnmanaged(std.ArrayListUnmanaged(u8)));
}

const ArrayListInfo = struct {
    Child: type,
    alignment: u29,

    fn get(comptime T: type) ?ArrayListInfo {
        if (@typeInfo(T) != .Struct or !@hasDecl(T, "Slice"))
            return null;

        const Slice = T.Slice;
        const ptr_info = switch (@typeInfo(Slice)) {
            .Pointer => |info| info,
            else => return null,
        };

        return ArrayListInfo{
            .Child = ptr_info.child,
            .alignment = ptr_info.alignment,
        };
    }
};

/// Returns `true` if `T` is a type created from the `std.HashMap` and `std.ArrayHashMap` family
/// of functions. This includes both Managed and Unmanaged versions.
pub fn aMap(comptime T: type) bool {
    return aMapManaged(T) or aMapUnmanaged(T);
}

test "itis.aMap" {
    try std.testing.expect(!itis.aMap(u8));
    try std.testing.expect(!itis.aMap([20]u8));
    try std.testing.expect(itis.aMap(std.AutoHashMap(u8, u8)));
    try std.testing.expect(itis.aMap(std.AutoHashMapUnmanaged(u8, u8)));
    try std.testing.expect(itis.aMap(std.AutoArrayHashMap(u8, u8)));
    try std.testing.expect(itis.aMap(std.AutoArrayHashMapUnmanaged(u8, u8)));
}

/// Returns `true` if `T` is a type created from the Managed versions of the `std.HashMap` and
/// std.ArrayHashMap` family of functions.
pub fn aMapManaged(comptime T: type) bool {
    return aHashMapManaged(T) or anArrayHashMapManaged(T);
}

test "itis.aMapManaged" {
    try std.testing.expect(!itis.aMapManaged(u8));
    try std.testing.expect(!itis.aMapManaged([20]u8));
    try std.testing.expect(itis.aMapManaged(std.AutoHashMap(u8, u8)));
    try std.testing.expect(!itis.aMapManaged(std.AutoHashMapUnmanaged(u8, u8)));
    try std.testing.expect(itis.aMapManaged(std.AutoArrayHashMap(u8, u8)));
    try std.testing.expect(!itis.aMapManaged(std.AutoArrayHashMapUnmanaged(u8, u8)));
}

/// Returns `true` if `T` is a type created from the Unmanaged versions of the `std.HashMap` and
/// std.ArrayHashMap` family of functions.
pub fn aMapUnmanaged(comptime T: type) bool {
    return aHashMapUnmanaged(T) or anArrayHashMapUnmanaged(T);
}

test "itis.aMapUnmanaged" {
    try std.testing.expect(!itis.aMapUnmanaged(u8));
    try std.testing.expect(!itis.aMapUnmanaged([20]u8));
    try std.testing.expect(!itis.aMapUnmanaged(std.AutoHashMap(u8, u8)));
    try std.testing.expect(itis.aMapUnmanaged(std.AutoHashMapUnmanaged(u8, u8)));
    try std.testing.expect(!itis.aMapUnmanaged(std.AutoArrayHashMap(u8, u8)));
    try std.testing.expect(itis.aMapUnmanaged(std.AutoArrayHashMapUnmanaged(u8, u8)));
}

/// Returns `true` if `T` is a type created from the `std.HashMap` family of functions. This
/// includes both Managed and Unmanaged versions.
pub fn aHashMap(comptime T: type) bool {
    return aHashMapManaged(T) or aHashMapUnmanaged(T);
}

test "itis.aHashMap" {
    try std.testing.expect(!itis.aHashMap(u8));
    try std.testing.expect(!itis.aHashMap([20]u8));
    try std.testing.expect(itis.aHashMap(std.AutoHashMap(u8, u8)));
    try std.testing.expect(itis.aHashMap(std.AutoHashMapUnmanaged(u8, u8)));
    try std.testing.expect(!itis.aHashMap(std.AutoArrayHashMap(u8, u8)));
    try std.testing.expect(!itis.aHashMap(std.AutoArrayHashMapUnmanaged(u8, u8)));
}

/// Returns `true` if `T` is a type created from  the Managed versions of the `std.HashMap` family
/// of functions.
pub fn aHashMapManaged(comptime T: type) bool {
    const info = HashMapInfo.get(T) orelse return false;
    if (info.Hash != u64)
        return false;

    comptime var i: usize = 1;
    inline while (i < 100) : (i += 1) {
        if (T == std.HashMap(info.K, info.V, info.Context, i))
            return true;
    }

    return false;
}

test "itis.aHashMapManaged" {
    try std.testing.expect(!itis.aHashMapManaged(u8));
    try std.testing.expect(!itis.aHashMapManaged([20]u8));
    try std.testing.expect(itis.aHashMapManaged(std.AutoHashMap(u8, u8)));
    try std.testing.expect(!itis.aHashMapManaged(std.AutoHashMapUnmanaged(u8, u8)));
    try std.testing.expect(!itis.aHashMapManaged(std.AutoArrayHashMap(u8, u8)));
    try std.testing.expect(!itis.aHashMapManaged(std.AutoArrayHashMapUnmanaged(u8, u8)));
}

/// Returns `true` if `T` is a type created from  the Unmanaged versions of the `std.HashMap`
/// family of functions.
pub fn aHashMapUnmanaged(comptime T: type) bool {
    const info = HashMapInfo.get(T) orelse return false;
    if (info.Hash != u64)
        return false;

    comptime var i: usize = 1;
    inline while (i < 100) : (i += 1) {
        if (T == std.HashMapUnmanaged(info.K, info.V, info.Context, i))
            return true;
    }

    return false;
}

test "itis.aHashMapUnmanaged" {
    try std.testing.expect(!itis.aHashMapUnmanaged(u8));
    try std.testing.expect(!itis.aHashMapUnmanaged([20]u8));
    try std.testing.expect(!itis.aHashMapUnmanaged(std.AutoHashMap(u8, u8)));
    try std.testing.expect(itis.aHashMapUnmanaged(std.AutoHashMapUnmanaged(u8, u8)));
    try std.testing.expect(!itis.aHashMapUnmanaged(std.AutoArrayHashMap(u8, u8)));
    try std.testing.expect(!itis.aHashMapUnmanaged(std.AutoArrayHashMapUnmanaged(u8, u8)));
}

/// Returns `true` if `T` is a type created from the `std.ArrayHashMap` family of functions. This
/// includes both Managed and Unmanaged versions.
pub fn anArrayHashMap(comptime T: type) bool {
    return anArrayHashMapManaged(T) or anArrayHashMapUnmanaged(T);
}

test "itis.anArrayHashMap" {
    try std.testing.expect(!itis.anArrayHashMap(u8));
    try std.testing.expect(!itis.anArrayHashMap([20]u8));
    try std.testing.expect(!itis.anArrayHashMap(std.AutoHashMap(u8, u8)));
    try std.testing.expect(!itis.anArrayHashMap(std.AutoHashMapUnmanaged(u8, u8)));
    try std.testing.expect(itis.anArrayHashMap(std.AutoArrayHashMap(u8, u8)));
    try std.testing.expect(itis.anArrayHashMap(std.AutoArrayHashMapUnmanaged(u8, u8)));
}

/// Returns `true` if `T` is a type created from the Managed versions of the `std.ArrayHashMap`
/// family of functions.
pub fn anArrayHashMapManaged(comptime T: type) bool {
    const info = HashMapInfo.get(T) orelse return false;
    if (info.Hash != u32)
        return false;

    return T == std.ArrayHashMap(info.K, info.V, info.Context, true) or
        T == std.ArrayHashMap(info.K, info.V, info.Context, false);
}

test "itis.anArrayHashMapManaged" {
    try std.testing.expect(!itis.anArrayHashMapManaged(u8));
    try std.testing.expect(!itis.anArrayHashMapManaged([20]u8));
    try std.testing.expect(!itis.anArrayHashMapManaged(std.AutoHashMap(u8, u8)));
    try std.testing.expect(!itis.anArrayHashMapManaged(std.AutoHashMapUnmanaged(u8, u8)));
    try std.testing.expect(itis.anArrayHashMapManaged(std.AutoArrayHashMap(u8, u8)));
    try std.testing.expect(!itis.anArrayHashMapManaged(std.AutoArrayHashMapUnmanaged(u8, u8)));
}

/// Returns `true` if `T` is a type created from the Unmanaged versions of the
/// `std.ArrayHashMap` family of functions.
pub fn anArrayHashMapUnmanaged(comptime T: type) bool {
    const info = HashMapInfo.get(T) orelse return false;
    if (info.Hash != u32)
        return false;

    return T == std.ArrayHashMapUnmanaged(info.K, info.V, info.Context, true) or
        T == std.ArrayHashMapUnmanaged(info.K, info.V, info.Context, false);
}

test "itis.anArrayHashMapUnmanaged" {
    try std.testing.expect(!itis.anArrayHashMapUnmanaged(u8));
    try std.testing.expect(!itis.anArrayHashMapUnmanaged([20]u8));
    try std.testing.expect(!itis.anArrayHashMapUnmanaged(std.AutoHashMap(u8, u8)));
    try std.testing.expect(!itis.anArrayHashMapUnmanaged(std.AutoHashMapUnmanaged(u8, u8)));
    try std.testing.expect(!itis.anArrayHashMapUnmanaged(std.AutoArrayHashMap(u8, u8)));
    try std.testing.expect(itis.anArrayHashMapUnmanaged(std.AutoArrayHashMapUnmanaged(u8, u8)));
}

const HashMapInfo = struct {
    K: type,
    V: type,
    Context: type,
    Hash: type,

    fn get(comptime T: type) ?HashMapInfo {
        if (@typeInfo(T) != .Struct)
            return null;
        if (@hasDecl(T, "Managed"))
            return get(T.Managed);
        if (!@hasDecl(T, "KV") or !@hasField(T, "ctx"))
            return null;
        if (@typeInfo(T.KV) != .Struct)
            return null;
        if (!@hasField(T.KV, "key") or !@hasField(T.KV, "value"))
            return null;

        const Context = std.meta.fieldInfo(T, .ctx).field_type;
        if (!@hasDecl(Context, "hash"))
            return null;

        const HashFn = @TypeOf(Context.hash);
        const Hash = switch (@typeInfo(HashFn)) {
            .Fn => |info| info.return_type orelse return null,
            else => return null,
        };

        return HashMapInfo{
            .K = std.meta.fieldInfo(T.KV, .key).field_type,
            .V = std.meta.fieldInfo(T.KV, .value).field_type,
            .Context = Context,
            .Hash = Hash,
        };
    }
};
