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
	    sudo apt-get install -y \
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
	    sudo apt-get update -y
	    # 安装最新版本的Docker CE
	    sudo apt-get install -y docker-ce
	    # 输出Docker的版本号来验证安装
	    docker --version
	fi
	
    # 构建Privasea代码
    sudo docker pull privasea/node-calc:v0.0.1
    # 拉取客户端
	sudo docker pull privasea/node-client:v0.0.1
    echo '====================== 部署完成 ==========================='
}

# 创建账号及密钥文件
function create_privasea_account(){
	
	mkdir -p $HOME/keys
	sudo docker run -it -v $HOME/keys:/app/keys privasea/node-client:v0.0.1 account
	echo '请备份账号信息!'
}

# 查看privasea节点日志查询
function view_logs() {
	read -p "请输入节点名称: " NODE_NAME
    sudo docker logs -f $NODE_NAME
}

# 卸载验证节点功能
function uninstall_node() {
	read -p "请输入节点名称: " NODE_NAME
    echo "确定要卸载Privasea验证节点吗？[Y/N]"
    read -r -p "请确认: " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            echo "开始卸载验证节点..."
            sudo docker stop $NODE_NAME
            sudo docker rm $NODE_NAME
            sudo docker rmi $NODE_NAME
            echo "验证节点卸载完成，$HOME/keys中保存了账户信息，被保留了下来，备份后手动删除即可。"
            ;;
        *)
            echo "取消卸载操作。"
            ;;
    esac
}

# 停止Privasea节点
function stop_node(){
	read -p "请输入节点名称: " NODE_NAME
	sudo docker stop $NODE_NAME
	echo "节点已停止。"
}

# 启动Privasea节点
function start_node(){
	read -p "请输入节点名称: " NODE_NAME
	read -p "请输入账号文件名: " ACCOUNT
	read -sp "请输入账号密码: " PASSWORD
	read -p "请输入公网IP: " PUBLIC_IP
	echo "是否有tBNB和TT(测试代币)？[Y/N]"
    read -r -p "请确认: " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            # 检查端口 8181 是否被占用
			ss -ltn | grep 8181 > /dev/null
			if [ $? -eq 0 ]; then
			    echo "端口 8181 已被占用，请检查并重启节点。"
			    exit 1
			else
			    echo "正在启动..."
			fi
		
			sudo docker run -d -p 8181:8181 -e HOST=$PUBLIC_IP:8181  -e KEYSTORE=$ACCOUNT -e KEYSTORE_PASSWORD=$PASSWORD  -v $HOME/keys:/app/config --name $NODE_NAME privasea/node-calc:v0.0.1
			echo "$NODE_NAME节点已启动"
            ;;
        *)
            echo "退出。"
            ;;
    esac
	
}

# 部署客户端
function install_privasea_client(){
	# 检查Docker是否已安装
	if [ -x "$(command -v docker)" ]; then
	    echo "Docker is already installed."
	else
	    echo "Docker is not installed. Installing Docker..."
	    # 更新apt包索引
	    sudo apt-get update
	    # 安装包以允许apt通过HTTPS使用仓库
	    sudo apt-get install -y \
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
	    sudo apt-get update -y
	    # 安装最新版本的Docker CE
	    sudo apt-get install -y docker-ce
	    # 输出Docker的版本号来验证安装
	    sudo docker --version
	fi
	
    # 构建客户端代码
	sudo docker pull privasea/node-client:v0.0.1
	echo '====================== 部署完成 ==========================='
}

# 启动客户端
function start_privasea_client(){

	read -p "请输入客户端名称: " CLIENT_NAME
	read -p "请输入账号文件名: " ACCOUNT
	read -sp "请输入账号密码: " PASSWORD
		
	sudo docker run -it -e KEYSTORE_PASSWORD=$PASSWORD  -v $HOME/keys:/app/config --name $CLIENT_NAME privasea/node-client:v0.0.1 task --keystore $ACCOUNT
}

# 停止客户端
function stop_privasea_client(){
	read -p "请输入客户端名称: " CLIENT_NAME
	sudo docker stop $CLIENT_NAME
}

# 查看客户端日志
function view_privasea_client_logs(){
	read -p "请输入客户端名称: " CLIENT_NAME
	sudo docker logs -f $CLIENT_NAME
}

# 卸载客户端
function uninstall_privasea_client(){
	read -p "请输入客户端名称: " CLIENT_NAME
    echo "确定要卸载客户端吗？[Y/N]"
    read -r -p "请确认: " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            echo "开始卸载客户端..."
            sudo docker stop $CLIENT_NAME
            sudo docker rm $CLIENT_NAME
            sudo docker rmi $CLIENT_NAME
            
            echo "客户端卸载完成，$HOME/keys中保存了账户信息，被保留了下来，备份后手动删除即可。"
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
        #echo "6. 卸载节点"
        echo "------------------客户端相关选项------------------"
        echo "21. 部署客户端"
        echo "22. 启动客户端"
        echo "23. 停止客户端"
        echo "24. 查看客户端日志"
        #echo "25. 卸载客户端"
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
        22) start_privasea_client ;;
        23) stop_privasea_client ;;
        24) view_privasea_client_logs ;;
        25) uninstall_privasea_client ;;

        0) echo "退出脚本。"; exit 0 ;;
        *) echo "无效选项，请重新输入。"; sleep 3 ;;
        esac
        echo "按任意键返回主菜单..."
        read -n 1
    done
}

# 显示主菜单
main_menu