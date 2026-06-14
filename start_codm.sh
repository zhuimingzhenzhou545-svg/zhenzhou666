#!/system/bin/sh
# 启动使命召唤手游并执行美化脚本

# 启动使命召唤手游
am start -n com.tencent.tmgp.codm/com.tencent.tmgp.codm.SplashActivity

# 等待游戏启动
sleep 5

# 执行美化脚本并自动输入选项 y, 1, 1, 2
(printf "y\n1\n1\n2\n") | /data/内核/使命/灰灰使命国服美化2.4.sh
