#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/Privasea.sh"

# 节点安装功能
function install_node() {

	# 检查Docker是否已安装
	if [ -x "$(command -v docker)" ]; then
	    echo "Docker is already installed."
	else
	    echo "Docker is not installed. Installing Docker..."
	    # 更新apt包索引
	    sudo apt-get update
	    # 安装包以允许apt通过HTTPS使用仓库
	    sudo apt-get install \
	        apt-transport-https \
	        ca-certificates \
	        curl \
	        software-properties-common
	    # 添加Docker的官方GPG密钥
	    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	    # 设置稳定仓库
	    sudo add-apt-repository \
	        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	        $(lsb_release -cs) \
	        stable"
	    # 再次更新apt包索引
	    sudo apt-get update
	    # 安装最新版本的Docker CE
	    sudo apt-get install docker-ce
	    # 输出Docker的版本号来验证安装
	    docker --version
	fi
	
    # 构建Privasea代码
    sudo docker pull privasea/node-calc:v0.0.1
    echo '====================== 部署完成 ==========================='
}

# 创建账号及密钥文件
function create_privasea_account(){
	# 拉取 Privasea 客户端
	docker pull privasea/node-client:v0.0.1
	mkdir -p $HOME/keys
	docker run -it -v $HOME/keys:/app/keys privasea/node-client:v0.0.1 account
	echo '请备份账号信息!'
}

# 查看privasea节点日志查询
function view_logs() {
	read -p "请输入节点名称: " NODE_NAME
    docker logs -f $NODE_NAME
}

# 卸载验证节点功能
function uninstall_node() {
	read -p "请输入节点名称: " NODE_NAME
    echo "确定要卸载Privasea验证节点吗？[Y/N]"
    read -r -p "请确认: " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            echo "开始卸载验证节点..."
            docker stop $NODE_NAME
            docker rm $NODE_NAME
            docker rmi $NODE_NAME
            echo "验证节点卸载完成。"
            ;;
        *)
            echo "取消卸载操作。"
            ;;
    esac
}

# 停止Privasea节点
function stop_node(){
	read -p "请输入节点名称: " NODE_NAME
	docker stop $NODE_NAME
}

# 启动Privasea节点
function start_node(){
	read -p "请输入节点名称: " NODE_NAME
	read -p "请输入账号文件名: " ACCOUNT
	read -p "请输入账号密码: " PASSWORD
	read -p "请输入公网IP: " PUBLIC_IP
	
	# 检查端口 8181 是否被占用
	ss -ltn | grep 8181 > /dev/null
	if [ $? -eq 0 ]; then
	    echo "端口 8181 已被占用，请检查并重启节点。"
	    exit 1
	else
	    echo "正在启动..."
	fi

	docker run -d -p 8181:8181 -e HOST=$PUBLIC_IP:8181  -e KEYSTORE=$ACCOUNT -e KEYSTORE_PASSWORD=$PASSWORD  -v $HOME/keys:/app/config --name $NODE_NAME privasea/node-calc:v0.0.1
	echo "$NODE_NAME节点已启动"
}

# 部署客户端
function install_privasea_client(){
	# 更新系统
	sudo apt update && sudo apt upgrade -y
	
	# 安装Docker
	curl -fsSL https://test.docker.com -o test-docker.sh
	sudo sh test-docker.sh
	sudo systemctl enable docker
	sudo systemctl start docker
	sudo groupadd docker
	sudo usermod -aG docker $USER
	docker version
	
    # 构建客户端代码
	docker pull privasea/node-client:v0.0.1
	
}

# 启动客户端
function start_privasea_client(){
	read -p "请输入客户端名称: " CLIENT_NAME
	read -p "请输入账号文件名: " ACCOUNT
	read -p "请输入账号密码: " PASSWORD
	
	docker run -it -e KEYSTORE_PASSWORD=$PASSWORD  -v $HOME/keys:/app/config --name $CLIENT_NAME privasea/node-client:v0.0.1 task --keystore $ACCOUNT
}

# 客户端提交任务
function submit_a_task(){
	echo "submit_a_task"
}

# 停止客户端
function stop_privasea_client(){
	read -p "请输入客户端名称: " CLIENT_NAME
	docker stop $CLIENT_NAME
}

# 查看客户端日志
function view_privasea_client_logs(){
	echo "view_privasea_client_logs"
}

# 卸载客户端
function uninstall_privasea_client(){
	read -p "请输入客户端名称: " CLIENT_NAME
    echo "确定要卸载客户端吗？[Y/N]"
    read -r -p "请确认: " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            echo "开始卸载客户端..."
            docker stop $CLIENT_NAME
            docker rm $CLIENT_NAME
            docker rmi $CLIENT_NAME
            echo "客户端卸载完成。"
            ;;
        *)
            echo "取消卸载操作。"
            ;;
    esac

}
# 主菜单
function main_menu() {
    while true; do
        clear
        echo "===============Privasea一键部署脚本==============="
    	echo "沟通电报群：https://t.me/lumaogogogo"
    	echo "最低配置：6C8G100G，Privanetix节点需要公网IP"
        echo "请选择要执行的操作:"
        echo "--------------Privanetix节点相关选项--------------"
        echo "1. 部署节点"
        echo "2. 创建账号"
        echo "3. 启动节点"
        echo "4. 停止节点"
        echo "5. 查询日志"
        echo "6. 卸载节点"
        echo "------------------客户端相关选项------------------"
        echo "21. 部署客户端"
        echo "22. 启动客户端"
        echo "23. 提交学习任务"
        echo "24. 停止客户端"
        echo "25. 查看客户端日志"
        echo "26. 卸载客户端"
        echo "-----------------------其他-----------------------"
        echo "0. 退出脚本exit"
        read -p "请输入选项: " OPTION
            
        case $OPTION in
        1) install_node ;;
        2) create_privasea_account ;;
        3) start_node ;;
        4) stop_node ;;
        5) view_logs ;;
        6) uninstall_node ;;
        
        21) install_privasea_client ;;
        21) start_privasea_client ;;
        21) submit_a_task ;;
        21) stop_privasea_client ;;
        21) view_privasea_client_logs ;;
        21) uninstall_privasea_client ;;

        0) echo "退出脚本。"; exit 0 ;;
        *) echo "无效选项，请重新输入。"; sleep 3 ;;
        esac
        echo "按任意键返回主菜单..."
        read -n 1
    done
}

# 显示主菜单
main_menu