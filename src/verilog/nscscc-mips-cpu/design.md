**THIS DOCUMENT IS CURRENTLY DEPRECATED**
---

# CPU设计说明

## CPU核心设计

CPU采用静态单发射流水线结构，流水线分为取指（IF）、译码（ID）、执行（EX）、写回（WB）四级，其中取指级内部拆分为两级：取指请求（IF_req）和取指等待（IF_wait），故总体上为五级流水。

### 各级的公共设计

流水线各级有一部分共通的设计，在此统一说明。

#### 握手信号 ####

流水线上下级之间通过一组valid/ready信号握手，以传递有效信号和实现阻塞控制。

```
|----|         |----|         |----|         |----|
|    |--valid->|    |--valid->|    |--valid->|    |
| IF |         | ID |         | EX |         | WB |
|    |<-ready--|    |<-ready--|    |<-ready--|    |
|----|         |----|         |----|         |----|
```

valid表示来自上一级的指令是有效指令，ready表示下一级可以接收指令。当一对valid/ready信号同时有效时，有效指令从上一级传递给下一级。

需要注意，每相邻两级的级间寄存器存在于上级的模块中，如IF/ID寄存器组存在于IF中，因此逻辑上“位于”ID内的指令实际上存储于IF的输出寄存器中。从IF到ID传递，其实是IF写IF输出寄存器的过程。

在各级模块的接口中，valid_o和ready_i用于和下级握手，valid_i和done_o用于和上级握手（由done_o生成到上一级的ready信号，下述）。

#### 前递处理 ####

前递的数据路径如下（注意级间寄存器位于上级的模块中，这里为了方便分离了出来）：

```
|----|    |-----|    |----|    |-----|    |----|
|    |    |     |    |    |    |     |    |    |
|    |    |     |    |    |    |     |    |    |
| ID |--->|ID/EX|----| EX |--->|EX/WB|----| WB |--->(reg_file)
|    |    |     |    |    | |  |     |    |    | |
|    |    |     |    |    | |  |     |    |    | |
|----|    |-----|    |----| |  |-----|    |----| |
   |                        |                    |
|-----------|               |                    |
|  Forward  |----------------                    |
|  Process  |-------------------------------------
|-----------|
```

EX、WB每一级传递到ID的前递信号如下：

|名称     |描述            |
|--------|----------------|
|fwd_addr|指令写入的寄存器号|
|fwd_data|前递数据         |
|fwd_ok  |前递数据已生成    |

ID的前递处理逻辑包含两部分：前递阻塞逻辑和前递数据选择逻辑。

当ID级指令读寄存器号等于某级的fwd_addr，且寄存器号不为0，称该情形为读地址命中。

- 若读地址命中，且前递数据尚未生成（fwd_ok为0），ID因前递而阻塞（fwd_stall有效）。为防止不必要的阻塞，对于不写回寄存器的指令，fwd_addr应设为0。

- 若读地址命中，且前递数据已生成（fwd_ok为1），fwd_rdata1和fwd_rdata2按指定的优先级选择前递数据或读寄存器堆的数据。

#### 例外处理 ####

例外传递路径如下：

```
                    interrupt                    commit
                        |                          ^
|----|    |-----|    |----|    |-----|    |----|   |
|    |    |     |    |    |    |     |    |    |   |
|    |    |     |    |    |    |     |    |    |   |
| IF |--->|IF/ID|----| ID |--->|ID/EX|----| EX |----
|    |    |     |    |    |    |     |    |    |
|    |    |     |    |    |    |     |    |    |
|----|    |-----|    |----|    |-----|    |----|
```

由于WB级不会发生例外，例外提交在EX级之后进行。EX级之前的例外通过exc和exccode传递，exc表示发生例外。注意发生例外的指令必须标记为有效，否则可能在传递过程中被丢弃。在例外提交时，也应同时判断有效标志和exc标志，以确保流水线内多条指令发生例外时只有第一条被提交（后面的指令被取消从而被标记为无效）。

例外取消路径如下：

```
|----|    |-----|    |----|    |-----|    |----|
|    |    |     |    |    |    |     |    |    |
|    |    |     |    |    |    |     |    |    |
| IF |    |IF/ID|    | ID |    |ID/EX|    | EX |
|    |    |     |    |    |    |     |    |    |
|    |    |     |    |    |    |     |    |    |
|----|    |-----|    |----|    |-----|    |----|
    |                 |  |                 |
    |cancel_i cancel_o|  |cancel_i   commit|
    |                 |  |                 |
    |------------------  ------------------|
    |                                      |
    ----------------------------------------
```

取消逻辑为组合逻辑，用于立即阻止前级指令的操作。ID级例外会取消IF级操作，EX级例外会取消IF和ID级的操作。注意cancel_o不需要依赖于cancel_i，因此不必搭建长延迟的取消链。

由于cancel_i持续时间可能很短，IF和ID中还需要相应的标志进行记录。以ID为例如下：

```
reg cancelled;
always @(posedge clk) begin
    if (!resetn) cancelled <= 1'b0;
    else if (done_o && ready_i) cancelled <= 1'b0;
    else if (cancel_i) cancelled <= 1'b1;
end
```

因此判断是否被取消时要同时检查cancel_i和cancelled。

#### 级内共通设计 ####

ID、EX、WB内部均有名为valid和done_o的信号（IF内也有类似信号，但由于IF内为两级流水，信号命名有所区别）。这两个信号的作用如下：

|名称   |描述                                 |
|------|-------------------------------------|
|valid |指示当前指令可以进行处理                |
|done_o|当前指令处理完成，即将在下一周期传递给下级|

不同于valid_i，valid既要求当前指令是上级传递而来的有效指令（valid_i），又要求指令未因发生例外而取消执行。取消包含两种情况，一是当前指令在之前的某级发生过例外（exc_i），另一种是因后面某级的指令发生例外而清空流水线（cancel_i）。

对于某些关键的控制信号（如寄存器堆写使能），这些信号对每条指令只能有效一拍，因此需要由valid和done_o同时控制，在编写RTL代码时需要注意这一点。

#### 由done_o生成到上级的ready信号 ####

为减少ready链带来的长延迟，各级由输出ready_o变更为输出done_o，并由外层模块生成真正的ready信号。

ready信号有效的情形有两种：下一级的ready信号有效，或者该级的指令为无效指令。对应的逻辑如下：

```
assign wb_ex_ready = wb_done || !ex_wb_valid;
assign ex_id_ready = ex_done && wb_ex_ready || !id_ex_valid;
assign id_if_ready = id_done && ex_id_ready || !if_id_valid;
```

优化时序后的逻辑如下：

```
assign wb_ex_ready = wb_done || !ex_wb_valid;
assign ex_id_ready = ex_done && wb_done || ex_done && !ex_wb_valid || !id_ex_valid;
assign id_if_ready = id_done && ex_done && wb_done || id_done && ex_done && !ex_wb_valid || id_done && !id_ex_valid || !if_id_valid;
```

### PC寄存器

PC寄存器的实现与IF输入valid寄存器的实现是相关联的：

```
reg [31:0] pc;
always @(posedge clk) begin
    if (!resetn) pc <= `VEC_RESET;
    else if (commit) pc <= vector;
    else if (branch && branch_ack) pc <= branch_pc;
    else if (if_ready) pc <= pc + 32'd4;
end

reg if_valid_r;
always @(posedge clk) begin
    if (!resetn) if_valid_r <= 1'b1;
    else if (commit) if_valid_r <= 1'b1;
    else if (id_cancel) if_valid_r <= 1'b0;
    else if (branch && branch_ack) if_valid_r <= 1'b0;
    else if (branched) if_valid_r <= 1'b1; 
end
```

对于例外处理，在ID级取消信号到来时valid置0以停止取指，在例外提交后开始取指，PC载入例外向量或恢复点。

对于分支跳转，因原始设计中if_ready加上pc+32'd4的延迟过长，故在跳转后只将目标地址写入PC，延迟一周期（branched）后再开始取指。

### 取指（IF）

TODO

### 译码（ID）

TODO

### 执行（EX）

TODO

### 写回（WB）

TODO