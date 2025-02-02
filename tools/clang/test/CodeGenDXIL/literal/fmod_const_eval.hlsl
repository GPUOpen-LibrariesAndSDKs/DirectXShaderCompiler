// RUN: %dxc -T vs_6_0 %s -E main | FileCheck %s
// RUN: not %dxc -T vs_6_0 %s -E main -DNO_FOLD 2>&1 | FileCheck %s --check-prefixes=NO_FOLD

// The code path for this case asserts, but the assert does not indicate a
// serious problem with internal state.  The invalid overload will either be
// constant folded away, or caught by the validator.
// UNSUPPORTED: asserts

// Ensure fmod is constant evaluated during codegen, or dxil const eval
// TODO: handle fp specials properly!

RWBuffer<float4> results : register(u0);

[shader("vertex")]
void main(bool b : B) {
    uint i = 0;

    // Literal float
    // 2.5, -2.5, 2.5, -2.5
    // CHECK: call void @dx.op.bufferStore.f32(i32 69, %dx.types.Handle %{{.+}}, i32 0, i32 undef, float 2.500000e+00, float -2.500000e+00, float 2.500000e+00, float -2.500000e+00, i8 15)
    results[i++] = float4(fmod(5.5, 3.0),
                          fmod(-5.5, 3.0),
                          fmod(5.5, -3.0),
                          fmod(-5.5, -3.0));

    // Explicit float
    // 2.5, -2.5, 2.5, -2.5
    // CHECK: call void @dx.op.bufferStore.f32(i32 69, %dx.types.Handle %{{.+}}, i32 1, i32 undef, float 2.500000e+00, float -2.500000e+00, float 2.500000e+00, float -2.500000e+00, i8 15)
    results[i++] = float4(fmod(5.5f, 3.0f),
                          fmod(-5.5f, 3.0f),
                          fmod(5.5f, -3.0f),
                          fmod(-5.5f, -3.0f));

#ifdef NO_FOLD
    // Currently, we rely on constant folding of DXIL ops to get rid of illegal
    // double overloads. If this doesn't happen, we expect a validation error.
    // Ternary operator can return literal type, while not being foldable due
    // non-constant condition.
    // NO_FOLD: error: validation errors
    // NO_FOLD: error: DXIL intrinsic overload must be valid.
    float result = fmod(-5.5, b ? 1.5 : 0.5);
    results[i++] = float4(result, 0, 0, 0);
#endif // NO_FOLD
}
