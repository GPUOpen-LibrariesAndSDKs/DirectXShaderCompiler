// RUN: %dxc -spirv -Od -T lib_6_8 %s | FileCheck %s

// Verify that NodeInputRecord can be passed to a called function and used."

struct loadStressRecord
{
    uint  data[29];
    uint3 grid : SV_DispatchGrid;
};

void loadStressWorker(
    inout DispatchNodeInputRecord<loadStressRecord> inputData,
    GroupNodeOutputRecords<loadStressRecord> outRec)
{
    uint val =  inputData.Get().data[0]; // problem line

    outRec.Get().data[0] = val + 61;
}

[Shader("node")]
[NodeMaxDispatchGrid(3, 1, 1)]
[NumThreads(16, 1, 1)]
void loadStress_16(DispatchNodeInputRecord<loadStressRecord> inputData,
    [MaxRecords(16)] NodeOutput<loadStressRecord> loadStressChild)
{
    loadStressWorker(inputData, loadStressChild.GetGroupNodeOutputRecords(1));
}

// CHECK: OpDecorateId [[TEMP:%[^ ]*]] PayloadNodeNameAMDX [[STR:%[0-9A-Za-z_]*]]
// CHECK-DAG: [[ZERO:%[^ ]*]] = OpConstant %{{[^ ]*}} 0
// CHECK-DAG: [[ONE:%[^ ]*]] = OpConstant %{{[^ ]*}} 1
// CHECK-DAG: [[STR:%[^ ]*]] = OpConstantStringAMDX "loadStressChild"
// CHECK: [[STRUCT:%[^ ]*]] = OpTypeStruct %{{[^ ]*}}
// CHECK: [[ARRAY:%[^ ]*]] = OpTypeNodePayloadArrayAMDX [[STRUCT]]
// CHECK: [[PTR:%[^ ]*]] = OpTypePointer NodePayloadAMDX [[ARRAY]]
// CHECK-DAG: [[TEMP]] = OpVariable [[PTR]] NodePayloadAMDX
// CHECK-DAG: [[TWO:%[^ ]*]] = OpConstant %{{[^ ]*}} 2
// CHECK: OpAllocateNodePayloadsAMDX [[TEMP]] [[TWO]] [[ONE]] [[ZERO]]
