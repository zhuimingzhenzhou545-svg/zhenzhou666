#!/system/bin/sh
# 电量追踪器 - Web服务器启动脚本
# 功能：在端口8888启动Web服务

LOG_DIR="/sdcard/BatteryTracker"
LOG_FILE="${LOG_DIR}/log.txt"
PID_WEB="/dev/battery_web.pid"
WEB_DIR="/data/local/BatteryTracker"
PORT=8888

# 创建目录
mkdir -p "${LOG_DIR}"
mkdir -p "${WEB_DIR}"

# 检查是否已运行
if [ -f "${PID_WEB}" ]; then
    OLD_PID=$(cat "${PID_WEB}")
    if kill -0 "${OLD_PID}" 2>/dev/null; then
        exit 0
    fi
fi

# 复制Web文件
mkdir -p "${WEB_DIR}"
cp /system/etc/BatteryTracker/*.html "${WEB_DIR}/" 2>/dev/null

# 写入PID
echo $$ > "${PID_WEB}"

# 方案1：使用 Python3 HTTP服务器
if command -v python3 >/dev/null 2>&1; then
    cat > "${WEB_DIR}/server.py" << 'PYEOF'
#!/usr/bin/env python3
import http.server
import os
import urllib.parse

LOG_FILE = "/sdcard/BatteryTracker/log.txt"
WEB_DIR = "/data/local/BatteryTracker"
PORT = 8888

class BatteryHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        if path == "/" or path == "/index.html":
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            html_path = os.path.join(WEB_DIR, "电量追踪器.html")
            if os.path.exists(html_path):
                with open(html_path, "rb") as f:
                    self.wfile.write(f.read())
            else:
                self.wfile.write(b"<h1>Web UI not found</h1>")
        elif path == "/api/data":
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.send_header("Cache-Control", "no-cache, no-store")
            self.end_headers()
            if os.path.exists(LOG_FILE):
                with open(LOG_FILE, "rb") as f:
                    self.wfile.write(f.read())
            else:
                self.wfile.write(b"")
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        if path == "/api/clear":
            try:
                if os.path.exists(LOG_FILE):
                    os.remove(LOG_FILE)
                self.send_response(200)
                self.send_header("Content-Type", "text/plain")
                self.end_headers()
                self.wfile.write(b"OK")
            except Exception as e:
                self.send_response(500)
                self.end_headers()
                self.wfile.write(b"Error")
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == "__main__":
    server = http.server.HTTPServer(("0.0.0.0", PORT), BatteryHandler)
    server.serve_forever()
PYEOF
    chmod 755 "${WEB_DIR}/server.py"
    nohup python3 "${WEB_DIR}/server.py" > /dev/null 2>&1 &
    echo "Python server started"

# 方案2：busybox httpd + CGI 代理
elif command -v busybox >/dev/null 2>&1; then
    mkdir -p "${WEB_DIR}/cgi-bin"
    cat > "${WEB_DIR}/cgi-bin/data" << 'BBEOF'
#!/system/bin/sh
echo "HTTP/1.1 200 OK"
echo "Content-Type: text/plain; charset=utf-8"
echo ""
cat /sdcard/BatteryTracker/log.txt 2>/dev/null || echo ""
BBEOF
    chmod 755 "${WEB_DIR}/cgi-bin/data"
    nohup busybox httpd -f -p ${PORT} -h "${WEB_DIR}" -c "/cgi-bin" > /dev/null 2>&1 &
    echo "busybox httpd started"

fi

exit 0
