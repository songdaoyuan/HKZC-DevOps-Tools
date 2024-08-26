#!/bin/bash

# code by songdaoyuan@20240826

# 工作原理
# 1.从 Gitee 拉取 fio 程序 -> 2.顺序和4K读写测试 -> 3.导出测试结果

# 使用方式
# 使用管理员账号或者管理员权限使用此脚本

# ToDo 增加多线程、循环测试取平均值 功能

GlobalVar_BaseDir="."

Font_Red="\033[31m"
Font_Yellow="\033[33m"
Font_Suffix="\033[0m"
Font_SkyBlue="\033[36m"

Msg_Error="${Font_Red}[ERROR]${Font_Suffix}"

function BenchFunc_PerformanceTest_Disk_RunTest() {
    GetFioApp
    BenchFunc_PerformanceTest_Disk_RunTest_FIO
}

function GetFioApp() {
    wget -P $GlobalVar_BaseDir https://gitee.com/songdaoyuan/hkzc-dev-ops-tools/raw/master/LinuxBench/fio.tar.gz && tar -xzf fio.tar.gz && chmod +x fio
    rm -f fio.tar.gz
}

# ${GlobalVar_BaseDir}"/fio 修改此代码以编辑fio执行文件的路径
function BenchExec_FIO() {
    if [ "$1" == "read" ] || [ "$1" == "randread" ]; then
        local rr && rr="$("${GlobalVar_BaseDir}"/fio -ioengine=libaio -rw="$1" -bs="$2" -size="$3" -direct=1 -iodepth="$4" -runtime="$5" -name="$6" --minimal)"
        local rra && rra=(${rr//;/ }) # Result Array
        local rss && rss="${rra[6]}"  # Result Score Speed (KB/s)
        local rsi && rsi="${rra[7]}"  # Result Score IOPS
    elif [ "$1" == "write" ] || [ "$1" == "randwrite" ]; then
        local rr && rr="$("${GlobalVar_BaseDir}"/fio -ioengine=libaio -rw="$1" -bs="$2" -size="$3" -direct=1 -iodepth="$4" -runtime="$5" -name="$6" --minimal)"
        local rra && rra=(${rr//;/ }) # Result Array
        local rss && rss="${rra[47]}" # Result Score Speed (KB/s)
        local rsi && rsi="${rra[48]}" # Result Score IOPS
    else
        echo -e "${Msg_Error} BenchExec_FIO(): invalid params ($1), please check parameter!"
        exit 1
    fi
    if [ "$rss" -ge "1024" ]; then # 结果 MB/s
        local rs && rs="$(echo "$rss" | awk '{printf "%.2f\n",$1/1024}')"
        local r && r="$rs MB/s ($rsi IOPS)"
    else # 结果 KB/s
        local r && r="$rss KB/s ($rsi IOPS)"
    fi
    echo -n "$r"
    rm -f "$6.0.0"
}

function BenchFunc_PerformanceTest_Disk_RunTest_FIO() {
    echo -e "\n ${Font_Yellow}-> Disk Performance Test (Using FIO, Direct mode, 32 IO-Depth)${Font_Suffix}\n"
    mkdir -p "${GlobalVar_BaseDir}/tmp" >/dev/null 2>&1

    # 顺序读 SEQ1M Q8T1
    echo -n -e " ${Font_Yellow}Sequential Read Test (1M-Block, QD=8, 1 Thread):${Font_Suffix}\t->\c"
    local sr1m_q8t1 && sr1m_q8t1="$(BenchExec_FIO "read" "1m" "1g" "8" "60" "${GlobalVar_BaseDir}/tmp/TestFile.bin")"
    echo -n -e "\r ${Font_Yellow}Sequential Read Test (1M-Block, QD=8, 1 Thread):${Font_Suffix}\t${Font_SkyBlue}$sr1m_q8t1${Font_Suffix}\n"
    Result_PerformanceTest_Disk_1MSeqRead_Q8T1=" Sequential Read Test (1M-Block, QD=8, 1 Thread):\t$sr1m_q8t1"
    # 顺序写 SEQ1M Q8T1
    echo -n -e " ${Font_Yellow}Sequential Write Test (1M-Block, QD=8, 1 Thread):${Font_Suffix}\t->\c"
    local sw1m_q8t1 && sw1m_q8t1="$(BenchExec_FIO "write" "1m" "1g" "8" "60" "${GlobalVar_BaseDir}/tmp/TestFile.bin")"
    echo -n -e "\r ${Font_Yellow}Sequential Write Test (1M-Block, QD=8, 1 Thread):${Font_Suffix}\t${Font_SkyBlue}$sw1m_q8t1${Font_Suffix}\n"
    Result_PerformanceTest_Disk_1MSeqWrite_Q8T1=" Sequential Write Test (1M-Block, QD=8, 1 Thread):\t$sw1m_q8t1"

    # 随机读 RND4K Q32T1
    echo -n -e " ${Font_Yellow}Read Test (4K-Block, QD=32, 1 Thread):${Font_Suffix}\t\t->\c"
    local rr4 && rr4="$(BenchExec_FIO "randread" "4k" "1g" "32" "60" "${GlobalVar_BaseDir}/tmp/TestFile.bin")"
    echo -n -e "\r ${Font_Yellow}Read  Test (4K-Block, QD=32, 1 Thread):${Font_Suffix}\t\t${Font_SkyBlue}$rr4${Font_Suffix}\n"
    Result_PerformanceTest_Disk_4KRandRead_Q32T1=" Random Read  Test (4K-Block, QD=32, 1 Thread):\t\t$rr4"
    # 随机写 RND4K Q32T1
    echo -n -e " ${Font_Yellow}Write Test (4K-Block, QD=32, 1 Thread):${Font_Suffix}\t\t->\c"
    local rw4 && rw4="$(BenchExec_FIO "randwrite" "4k" "1g" "32" "60" "${GlobalVar_BaseDir}/tmp/TestFile.bin")"
    echo -n -e "\r ${Font_Yellow}Write Test (4K-Block, QD=32, 1 Thread):${Font_Suffix}\t\t${Font_SkyBlue}$rw4${Font_Suffix}\n"
    Result_PerformanceTest_Disk_4KRandWrite_Q32T1=" Random Write Test (4K-Block, QD=32, 1 Thread):\t\t$rw4"

    # 随机读 128K
    # echo -n -e " ${Font_Yellow}Read Test (128K-Block):${Font_Suffix}\t->\c"
    # local rr128 && rr128="$(BenchExec_FIO "randread" "128k" "100m" "32" "60" "${GlobalVar_BaseDir}/tmp/TestFile.bin")"
    # echo -n -e "\r ${Font_Yellow}Read  Test (128K-Block):${Font_Suffix}\t${Font_SkyBlue}$rr128${Font_Suffix}\n"
    # Result_PerformanceTest_Disk_128KRandRead=" Random Read  Test (128K-Block):\t$rr128"

    # 随机写 128K
    # echo -n -e " ${Font_Yellow}Write Test (128K-Block):${Font_Suffix}\t->\c"
    # local rw128 && rw128="$(BenchExec_FIO "randwrite" "128k" "100m" "32" "60" "${GlobalVar_BaseDir}/tmp/TestFile.bin")"
    # echo -n -e "\r ${Font_Yellow}Write Test (128K-Block):${Font_Suffix}\t${Font_SkyBlue}$rw128${Font_Suffix}\n"
    # Result_PerformanceTest_Disk_128KRandWrite=" Random Write Test (128K-Block):\t$rw128"

}

# -> 结果输出
function BenchAPI_GenerateReport_PerformanceTest_Disk() {
    mkdir -p "${GlobalVar_BaseDir}/tmp/result" >/dev/null 2>&1
    local v_resfile && v_resfile="${GlobalVar_BaseDir}/tmp/result/performance_disk.restmp"
    echo -e "\n -> Disk Performance Test (Using FIO, Direct mode, 32 IO-Depth)\n" >"$v_resfile"
    {
        # 顺序读写性能
        echo -e "作为参考, 机械硬盘的顺序读写性能为200MB/S左右\n
                SATA协议固态硬盘的读写速率在500MB/S左右\n
                使用PCIE接口的固态硬盘读速率可以轻松突破1GB/S, 而写速率一般会低于读速率"
        echo -e "$Result_PerformanceTest_Disk_1MSeqRead_Q8T1"
        echo -e "$Result_PerformanceTest_Disk_1MSeqWrite_Q8T1"
        # 4K读写性能
        echo -e "作为参考, 机械硬盘的随机读写性能为1.5MB/S左右, 非常糟糕\n
                固态硬盘的读写速率在50 - 100MB/S左右\n"
        echo -e "$Result_PerformanceTest_Disk_4KRandRead_Q32T1"
        echo -e "$Result_PerformanceTest_Disk_4KRandWrite_Q32T1"

    } >>"$v_resfile"
}

BenchFunc_PerformanceTest_Disk_RunTest
BenchAPI_GenerateReport_PerformanceTest_Disk
