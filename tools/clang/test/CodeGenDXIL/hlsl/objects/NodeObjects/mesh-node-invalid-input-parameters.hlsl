// RUN: %dxc -T lib_6_9 -verify %s

// REQUIRES: dxil-1-9

// Test that invalid mesh node input parameters fail with appropriate diagnostics

struct RECORD {
  uint3 gtid;
};

[Shader("node")]
[numthreads(4,4,4)]
[NodeMaxDispatchGrid(4,4,4)]
[NodeLaunch("mesh")]
[OutputTopology("triangle")]
void node02_maxdisp(DispatchNodeInputRecord<RECORD> input, // expected-error {{Broadcasting/Mesh node shader 'node02_maxdisp' with NodeMaxDispatchGrid attribute must declare an input record containing a field with SV_DispatchGrid semantic}}
 uint3 GTID : SV_GroupThreadID ) {
}
