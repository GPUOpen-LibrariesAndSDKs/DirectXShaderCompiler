// RUN: %dxc -spirv -Od -T lib_6_8 %s | FileCheck %s

// Check the WaveSize attribute is accepted by work graph nodes
// and appears in the metadata

struct INPUT_RECORD
{
  uint DispatchGrid1 : SV_DispatchGrid;
  uint2 a;
};

[Shader("node")]
[NodeLaunch("broadcasting")]
[NumThreads(1,1,1)]
[NodeMaxDispatchGrid(64,1,1)]
[WaveSize(4)]
void node01(DispatchNodeInputRecord<INPUT_RECORD> input) { }

[Shader("node")]
[NodeLaunch("broadcasting")]
[NumThreads(1,1,1)]
[NodeMaxDispatchGrid(64,1,1)]
[WaveSize(8)]
void node02(DispatchNodeInputRecord<INPUT_RECORD> input) { }

[Shader("node")]
[NodeLaunch("coalescing")]
[NumThreads(1,1,1)]
[WaveSize(16)]
void node03(RWGroupNodeInputRecords<INPUT_RECORD> input) { }

[Shader("node")]
[NodeLaunch("thread")]
[WaveSize(32)]
void node04(ThreadNodeInputRecord<INPUT_RECORD> input) { }

// CHECK: OpCapability SubgroupDispatch
// CHECK: OpEntryPoint GLCompute [[NODE01:%[^ ]*]] "node01"
// CHECK: OpEntryPoint GLCompute [[NODE02:%[^ ]*]] "node02"
// CHECK: OpEntryPoint GLCompute [[NODE03:%[^ ]*]] "node03"
// CHECK: OpEntryPoint GLCompute [[NODE04:%[^ ]*]] "node04"
// CHECK-DAG: OpExecutionModeId [[NODE01]] MaxNumWorkgroupsAMDX [[U64:%[^ ]*]] [[U1:%[0-9A-Za-z_]*]]
// CHECK-SAME: [[U1]]
// CHECK-DAG: OpExecutionModeId [[NODE02]] MaxNumWorkgroupsAMDX [[U64]] [[U1]] [[U1]]
// CHECK-DAG: OpExecutionMode [[NODE01]] SubgroupSize 4
// CHECK-DAG: OpExecutionMode [[NODE02]] SubgroupSize 8
// CHECK-DAG: OpExecutionMode [[NODE03]] SubgroupSize 16
// CHECK-DAG: OpExecutionMode [[NODE04]] SubgroupSize 32
// CHECK: OpMemberDecorate %{{[^ ]*}} 0 PayloadDispatchIndirectAMDX
// CHECK: [[UINT:%[^ ]*]] = OpTypeInt 32 0
// CHECK-DAG: [[U64]] = OpConstant [[UINT]] 64
// CHECK-DAG: [[U1]] = OpConstant [[UINT]] 1
