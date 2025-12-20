#!/usr/bin/env bash

#==============================================================================
# quickstart_tools.sh - Shared utilities for AI Quickstart projects
#
# A consolidated library of reusable functions for Akamai Cloud (Linode)
# AI quickstart deployments.
#
# Usage:
#   # Local sourcing
#   source "${SCRIPT_DIR}/script/quickstart_tools.sh"
#
#   # Remote sourcing
#   source <(curl -fsSL https://raw.githubusercontent.com/linode/ai-quickstart-tools/main/quickstart_tools.sh)
#
# Repository: https://github.com/linode/ai-quickstart-tools
#==============================================================================

#==============================================================================
# GUARD: Prevent double-sourcing
#==============================================================================
[ -n "${_QS_TOOLS_LOADED:-}" ] && return 0
readonly _QS_TOOLS_LOADED=1

#==============================================================================
# SECTION 1: Constants & Colors
#==============================================================================

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# API Constants
readonly API_BASE="https://api.linode.com/v4"
readonly OAUTH_CLIENT_ID="5823b4627e45411d18e9"
readonly OAUTH_LOGIN_URL="https://login.linode.com/oauth/authorize"

#==============================================================================
# SECTION 2: Embedded Assets (Logo)
#==============================================================================

# Show Akamai banner
# Usage: show_banner
show_banner() {
    clear

    # Gradient colors from left to right (optimized for both dark and light backgrounds)
    local C1='\033[38;2;0;145;200m'    # #0091c8 - darker cyan
    local C2='\033[38;2;0;155;210m'    # #009bd2
    local C3='\033[38;2;0;165;220m'    # #00a5dc
    local C4='\033[38;2;0;176;230m'    # #00b0e6
    local C5='\033[38;2;20;186;235m'   # #14baeb
    local C6='\033[38;2;40;196;240m'   # #28c4f0 - lighter cyan

    echo -e "
 ${C1} █████╗ ${C1} ██╗  ██╗${C1}  █████╗ ${C2} ███╗   ███╗${C3}  █████╗ ${C4} ██╗
 ${C1}██╔══██╗${C1} ██║ ██╔╝${C1} ██╔══██╗${C2} ████╗ ████║${C3} ██╔══██╗${C4} ██║
 ${C1}███████║${C1} █████╔╝ ${C1} ███████║${C2} ██╔████╔██║${C3} ███████║${C4} ██║
 ${C1}██╔══██║${C1} ██╔═██╗ ${C1} ██╔══██║${C2} ██║╚██╔╝██║${C3} ██╔══██║${C4} ██║
 ${C1}██║  ██║${C1} ██║  ██╗${C1} ██║  ██║${C2} ██║ ╚═╝ ██║${C3} ██║  ██║${C4} ██║
 ${C1}╚═╝  ╚═╝${C1} ╚═╝  ╚═╝${C1} ╚═╝  ╚═╝${C2} ╚═╝     ╚═╝${C3} ╚═╝  ╚═╝${C4} ╚═╝

 ${C1}██╗${C1} ███╗   ██╗${C2} ███████╗${C3} ███████╗${C4} ██████╗ ${C4} ███████╗${C5} ███╗   ██╗${C6}  ██████╗${C6} ███████╗
 ${C1}██║${C1} ████╗  ██║${C2} ██╔════╝${C3} ██╔════╝${C4} ██╔══██╗${C4} ██╔════╝${C5} ████╗  ██║${C6} ██╔════╝${C6} ██╔════╝
 ${C1}██║${C1} ██╔██╗ ██║${C2} █████╗  ${C3} █████╗  ${C4} ██████╔╝${C4} █████╗  ${C5} ██╔██╗ ██║${C6} ██║     ${C6} █████╗
 ${C1}██║${C1} ██║╚██╗██║${C2} ██╔══╝  ${C3} ██╔══╝  ${C4} ██╔══██╗${C4} ██╔══╝  ${C5} ██║╚██╗██║${C6} ██║     ${C6} ██╔══╝
 ${C1}██║${C1} ██║ ╚████║${C2} ██║     ${C3} ███████╗${C4} ██║  ██║${C4} ███████╗${C5} ██║ ╚████║${C6} ╚██████╗${C6} ███████╗
 ${C1}╚═╝${C1} ╚═╝  ╚═══╝${C2} ╚═╝     ${C3} ╚══════╝${C4} ╚═╝  ╚═╝${C4} ╚══════╝${C5} ╚═╝  ╚═══╝${C6}  ╚═════╝${C6} ╚══════╝

 ${C1} ██████╗${C2} ██╗     ${C3}  ██████╗ ${C4} ██╗   ██╗${C5} ██████╗
 ${C1}██╔════╝${C2} ██║     ${C3} ██╔═══██╗${C4} ██║   ██║${C5} ██╔══██╗
 ${C1}██║     ${C2} ██║     ${C3} ██║   ██║${C4} ██║   ██║${C5} ██║  ██║
 ${C1}██║     ${C2} ██║     ${C3} ██║   ██║${C4} ██║   ██║${C5} ██║  ██║
 ${C1}╚██████╗${C2} ███████╗${C3} ╚██████╔╝${C4} ╚██████╔╝${C5} ██████╔╝
 ${C1} ╚═════╝${C2} ╚══════╝${C3}  ╚═════╝ ${C4}  ╚═════╝ ${C5} ╚═════╝
${NC}"

    echo ""
}

#==============================================================================
# SECTION 3: Output/Logging Functions (Public)
#==============================================================================

# Log to file (strips color codes)
# Usage: log_to_file <level> <message>
# Requires LOG_FILE to be set
log_to_file() {
    [ -z "${LOG_FILE:-}" ] && return 0
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    local level="$1"
    shift
    # Strip ANSI color codes and log
    echo "[$timestamp] [$level] $*" | sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE"
}

# Print colored message
# Usage: msg <color> <message>
msg() {
    local color="$1"
    shift
    echo -e "${color}$*${NC}"
}

# Alias for backward compatibility (used by deploy.sh, delete.sh)
print_msg() {
    msg "$@"
}

# Print progress message (overwrites current line)
# Usage: progress <color> <message>
progress() {
    local color="$1"
    shift
    echo -en "\r\033[K${color}$*${NC}"
}

# Add bottom spacing
# Usage: scroll_up <bottom_spacing>
scroll_up() {
    local bottom_spacing="${1:-5}"
    if [ "$bottom_spacing" -gt 0 ]; then
        local j
        for j in $(seq 1 "$bottom_spacing"); do
            printf '\n' >&2
        done
        printf '\033[%dA' "$bottom_spacing" >&2
    fi
}

# Print error and exit
# Usage: error_exit <message>
error_exit() {
    local message="$1"
    msg "$RED" "❌ ERROR: $message"
    log_to_file "ERROR" "$message"
    exit 1
}

# Print success message
# Usage: success <message>
success() {
    msg "$GREEN" "✅ $*"
}

# Print info message
# Usage: info <message>
info() {
    msg "$CYAN" "ℹ️  $*"
}

# Print warning message
# Usage: warn <message>
warn() {
    msg "$YELLOW" "⚠️  $*"
}

# Print step header
# Usage: show_step <message>
show_step() {
    echo "------------------------------------------------------"
    msg "$BOLD" "$*"
    echo "------------------------------------------------------"
    echo ""
}

#==============================================================================
# SECTION 4: Utility Functions (Public)
#==============================================================================

# Ensure jq is available (auto-install if missing)
ensure_jq() {
    command -v jq &>/dev/null && jq --version &>/dev/null && return 0
    echo "jq not found. Attempting to install..." >&2
    local jq_base="https://github.com/jqlang/jq/releases/download/jq-1.8.1"

    # Windows Git Bash
    if [[ "$OSTYPE" == "msys" || -n "${MSYSTEM:-}" ]]; then
        curl -fsSL -o "/usr/bin/jq.exe" "$jq_base/jq-windows-amd64.exe" 2>/dev/null && chmod +x /usr/bin/jq.exe && jq --version &>/dev/null && return 0
        echo "Failed. Run: curl -L -o /usr/bin/jq.exe $jq_base/jq-windows-amd64.exe" >&2 && return 1
    fi
    # macOS - try brew first, then download binary
    if [[ "$OSTYPE" == "darwin"* ]]; then
        command -v brew &>/dev/null && brew install -q jq &>/dev/null && jq --version &>/dev/null && return 0
        local arch="amd64" && [[ "$(uname -m)" == "arm64" ]] && arch="arm64"
        curl -fsSL -o "/usr/local/bin/jq" "$jq_base/jq-macos-$arch" 2>/dev/null && chmod +x /usr/local/bin/jq && jq --version &>/dev/null && return 0
        echo "Failed. Run: sudo curl -L -o /usr/local/bin/jq $jq_base/jq-macos-$arch && sudo chmod +x /usr/local/bin/jq" >&2 && return 1
    fi
    # Linux - apt/dnf/yum
    command -v apt &>/dev/null && sudo apt-get install -y -qq jq &>/dev/null && jq --version &>/dev/null && return 0
    command -v dnf &>/dev/null && sudo dnf install -y -q jq &>/dev/null && jq --version &>/dev/null && return 0
    command -v yum &>/dev/null && sudo yum install -y -q jq &>/dev/null && jq --version &>/dev/null && return 0

    echo "Could not auto install jq. Please install manually." >&2 && return 1
}

#==============================================================================
# SECTION 5: Interactive Selection (Public)
#==============================================================================

# Interactive menu selection with default support
# Usage: ask_selection <prompt> <options_array_name> <default_index> <index_var> [default_label] [bottom_spacing]
ask_selection() {
    local prompt_text="$1"
    local options_array_name="$2"
    local default_index="${3:-}"
    local index_var_name="$4"
    local default_label="${5:-(default)}"
    local bottom_spacing="${6:-5}"

    # Get array length using eval (compatible with bash 3.2+)
    local array_length
    eval "array_length=\${#${options_array_name}[@]}"

    # Validate that array is not empty
    if [ "$array_length" -eq 0 ]; then
        msg "$RED" "Error: Options array is empty" >&2
        return 1
    fi

    # Validate default index
    if [ -n "$default_index" ] && [ "$default_index" != "0" ]; then
        if ! [[ "$default_index" =~ ^[0-9]+$ ]] || [ "$default_index" -lt 1 ] || [ "$default_index" -gt "$array_length" ]; then
            msg "$RED" "Error: Invalid default index: $default_index (must be 1-${array_length})" >&2
            return 1
        fi
    else
        default_index=""
    fi

    # Display options
    echo "" >&2
    local i
    for i in $(seq 0 $((array_length - 1))); do
        local display_num=$((i + 1))
        local option
        eval "option=\"\${${options_array_name}[$i]}\""

        if [ -n "$default_index" ] && [ "$display_num" -eq "$default_index" ]; then
            echo -e "  ${CYAN}${display_num}.${NC} ${YELLOW}${option}${NC} ${default_label}" >&2
        else
            echo -e "  ${CYAN}${display_num}.${NC} ${option}" >&2
        fi
    done

    echo "" >&2

    scroll_up "$bottom_spacing"

    # Prompt for selection (with range indicator)
    local selection
    local range_text="(1-${array_length})"
    while true; do
        if [ -n "$default_index" ]; then
            read -r -p "$(echo -e "${YELLOW}${prompt_text} ${range_text} [default: ${default_index}]:${NC} ")" selection </dev/tty
        else
            read -r -p "$(echo -e "${YELLOW}${prompt_text} ${range_text}:${NC} ")" selection </dev/tty
        fi

        # Use default if empty input and default is set
        if [ -z "$selection" ] && [ -n "$default_index" ]; then
            selection="$default_index"
        fi

        # Validate input is a number in range
        if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "$array_length" ]; then
            msg "$RED" "Please enter a number between 1 and ${array_length}." >&2
            continue
        fi

        break
    done

    # Store result in caller's variable (1-based index)
    eval "${index_var_name}='${selection}'"

    return 0
}

# Interactive text input with validation
# Usage: ask_input <prompt> <default_value> <validation_func> <error_msg> <result_var> [bottom_spacing]
# Parameters:
#   prompt          - Prompt text to display
#   default_value   - Default value (can be empty)
#   validation_func - Name of validation function (must return 0 for valid, 1 for invalid)
#   error_msg       - Error message to show on validation failure
#   result_var      - Name of variable to store the result
#   bottom_spacing  - Number of blank lines to add below prompt (default: 5)
# Example:
#   ask_input "Enter instance label" "my-instance" "validate_instance_label" "Invalid label format" label_result
ask_input() {
    local prompt_text="$1"
    local default_value="${2:-}"
    local validation_func="$3"
    local error_msg="$4"
    local result_var="$5"
    local bottom_spacing="${6:-5}"

    scroll_up "$bottom_spacing"

    local user_input
    while true; do
        if [ -n "$default_value" ]; then
            read -r -p "$(echo -e "${YELLOW}${prompt_text} ${NC}[default: ${default_value}]: ")" user_input </dev/tty
        else
            read -r -p "$(echo -e "${YELLOW}${prompt_text}:${NC} ")" user_input </dev/tty
        fi

        # Use default if empty input and default is set
        if [ -z "$user_input" ] && [ -n "$default_value" ]; then
            user_input="$default_value"
        fi

        # Skip validation if no validation function provided
        if [ -z "$validation_func" ]; then
            break
        fi

        # Run validation function
        if "$validation_func" "$user_input" > /dev/null 2>&1; then
            break
        else
            msg "$RED" "$error_msg"
        fi
    done

    # Store result in caller's variable
    eval "${result_var}='${user_input}'"

    return 0
}

# Interactive password input with confirmation and auto-generation
# Usage: ask_password <result_var> [bottom_spacing]
# Parameters:
#   result_var      - Name of variable to store the result
#   bottom_spacing  - Number of blank lines to add below prompt (default: 5)
# Example:
#   ask_password INSTANCE_PASSWORD
ask_password() {
    local result_var="$1"
    local bottom_spacing="${2:-5}"

    scroll_up "$bottom_spacing"

    # Ask if user wants to auto-generate
    local auto_generate
    read -r -p "$(echo -e ${YELLOW}Auto-generate a secure root password? [Y/n]:${NC} )" auto_generate </dev/tty

    if [[ "${auto_generate:-Y}" =~ ^[Yy]$ ]]; then
        local generated_password
        generated_password=$(generate_root_password)
        [ -z "$generated_password" ] || [ ${#generated_password} -lt 10 ] && error_exit "Failed to generate password"
        log_to_file "INFO" "Password auto-generated: $generated_password"
        eval "${result_var}='${generated_password}'"
        success "Password auto-generated"
        return 0
    fi

    # Manual password entry
    local user_password
    while true; do
        read -s -r -p "$(echo -e ${YELLOW}Enter root password:${NC} )" user_password </dev/tty
        echo ""

        if ! validate_root_password "$user_password"; then
            info "Password requirements: min 11 chars, must include uppercase, lowercase, numbers, and special characters"
            continue
        fi

        read -s -r -p "$(echo -e ${YELLOW}Confirm password:${NC} )" user_password_confirm </dev/tty
        echo ""

        if [ "$user_password" = "$user_password_confirm" ]; then
            eval "${result_var}='${user_password}'"
            log_to_file "INFO" "User typed password: *************"
            success "Password accepted"
            break
        fi
        warn "Passwords do not match. Please try again."
    done
}

#==============================================================================
# SECTION 6: Internal Helper Functions (Private - prefixed with _)
#==============================================================================

#------------------------------------------------------------------------------
# Authentication helpers
#------------------------------------------------------------------------------

# Find linode-cli config file
_find_config_file() {
    echo "${LINODE_CLI_CONFIG:-$([ -f "$HOME/.linode-cli" ] && echo "$HOME/.linode-cli" || echo "${XDG_CONFIG_HOME:-$HOME/.config}/linode-cli")}"
}

# Parse INI file value
_get_ini_value() {
    awk -F '=' -v s="[$2]" -v k="$3" '$0==s{f=1;next}/^\[/{f=0}f&&$1~"^[ \t]*"k"[ \t]*$"{gsub(/^[ \t]+|[ \t]+$/,"",$2);print $2;exit}' "$1"
}

#------------------------------------------------------------------------------
# OAuth helpers
#------------------------------------------------------------------------------

# Check OAuth dependencies
_check_oauth_dependencies() {
    local missing=()

    if ! command -v curl &> /dev/null; then
        missing+=("curl")
    fi

    local has_server=false
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
        if command -v powershell.exe &> /dev/null || command -v pwsh.exe &> /dev/null; then
            has_server=true
        elif command -v python3 &> /dev/null; then
            has_server=true
        fi
    else
        if command -v nc &> /dev/null; then
            has_server=true
        elif command -v python3 &> /dev/null; then
            has_server=true
        fi
    fi

    if [ "$has_server" = false ]; then
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
            missing+=("PowerShell or Python 3")
        else
            missing+=("netcat or Python 3")
        fi
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        msg "$RED" "❌ Missing dependencies: ${missing[*]}" >&2
        return 1
    fi
    return 0
}

# Open URL in browser (cross-platform)
_open_browser() {
    local url="$1"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$url" 2>/dev/null || true
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
        start "$url" 2>/dev/null || cmd.exe /c start "$url" 2>/dev/null || true
    elif grep -qi microsoft /proc/version 2>/dev/null || grep -qi wsl /proc/version 2>/dev/null; then
        if command -v powershell.exe &> /dev/null; then
            local escaped_url="${url//\'/\'\'}"
            powershell.exe -NoProfile -Command "Start-Process '${escaped_url}'" 2>/dev/null || true
        elif command -v wslview &> /dev/null; then
            wslview "$url" 2>/dev/null || true
        elif command -v cmd.exe &> /dev/null; then
            cmd.exe /c "start \"\" \"$url\"" 2>/dev/null || true
        else
            return 1
        fi
    elif command -v xdg-open &> /dev/null; then
        xdg-open "$url" 2>/dev/null || true
    else
        return 1
    fi
}

# Find an available port
_find_available_port() {
    local port
    local port_list
    if command -v shuf &> /dev/null; then
        port_list=$(shuf -i 8000-9000 -n 20)
    else
        port_list=$(seq 8000 8050)
    fi

    for port in $port_list; do
        if ! nc -z localhost "$port" 2>/dev/null && ! netstat -an 2>/dev/null | grep -q ":${port} "; then
            echo "$port"
            return 0
        fi
    done
    return 1
}

# Create HTML landing page for OAuth callback
_create_landing_page() {
    local port="$1"
    cat <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Authentication Success</title>
    <meta charset="UTF-8">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Arial, sans-serif;
            text-align: center;
            padding: 50px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            border-radius: 8px;
            padding: 40px;
            max-width: 500px;
            margin: 0 auto;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h2 { color: #02b159; margin-bottom: 20px; }
        .success { font-size: 48px; margin-bottom: 10px; }
        .info { color: #666; margin-top: 20px; line-height: 1.6; }
        .countdown {
            font-size: 24px;
            font-weight: bold;
            color: #02b159;
            margin-top: 15px;
        }
        .hint {
            color: #999;
            font-size: 14px;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="success">✓</div>
        <h2>Authentication Successful</h2>
        <p>Token has been sent to your terminal.</p>
        <p class="info">Return to your terminal to continue.</p>
        <div class="countdown" id="countdown">Closing in 5...</div>
        <p class="hint">Press Enter or Esc to close now</p>
    </div>
    <script>
        function sendToken(retries) {
            var r = new XMLHttpRequest();
            r.open('GET', 'http://localhost:PORT/token/' + window.location.hash.substr(1));
            r.timeout = 2000;
            r.onerror = r.ontimeout = function() {
                if (retries > 0) setTimeout(function() { sendToken(retries - 1); }, 300);
            };
            r.send();
        }
        sendToken(10);
        var secondsLeft = 5;
        var countdownElement = document.getElementById('countdown');
        function updateCountdown() {
            countdownElement.textContent = 'Closing in ' + secondsLeft + '...';
        }
        function attemptClose() {
            countdownElement.textContent = 'Closing...';
            window.close();
            if (window.opener) {
                window.opener = null;
                window.close();
            }
            setTimeout(function() {
                countdownElement.innerHTML = '<span style="color: #ff6b6b;">Please close this tab manually (Ctrl+W / Cmd+W)</span>';
            }, 500);
        }
        var countdownInterval = setInterval(function() {
            secondsLeft--;
            if (secondsLeft > 0) {
                updateCountdown();
            } else {
                clearInterval(countdownInterval);
                attemptClose();
            }
        }, 1000);
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Enter' || event.key === 'Escape') {
                clearInterval(countdownInterval);
                attemptClose();
            }
        });
        window.focus();
    </script>
</body>
</html>
EOF
}

# Start server using Python
_start_python_server() {
    local port="$1"
    local landing_page="$2"

    msg "$CYAN" "Starting Python HTTP server for OAuth callback (port: $port)" >&2

    python3 - "$port" "$landing_page" <<'PYTHON_EOF'
import sys
import re
from http.server import HTTPServer, BaseHTTPRequestHandler

port = int(sys.argv[1])
landing_page = sys.argv[2]
token = None

class OAuthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        global token
        if "token" in self.path:
            match = re.search(r"access_token=([^&\s]+)", self.path)
            if match:
                token = match.group(1)
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(landing_page.encode('utf-8'))
    def log_message(self, format, *args):
        pass

server = HTTPServer(("localhost", port), OAuthHandler)
while token is None:
    server.handle_request()
print(token)
PYTHON_EOF
}

# Start server using PowerShell (Windows only)
_start_powershell_server() {
    local port="$1"
    local landing_page="$2"
    local escaped_page="${landing_page//\'/\'\'}"
    local ps_cmd="powershell.exe"
    if command -v pwsh.exe &> /dev/null; then
        ps_cmd="pwsh.exe"
    fi

    msg "$CYAN" "Starting PowerShell HTTP server for OAuth callback (port: $port)" >&2

    "$ps_cmd" -Command "
        \$landingPage = '$escaped_page'
        \$listener = New-Object System.Net.HttpListener
        \$listener.Prefixes.Add('http://localhost:$port/')
        \$listener.Start()
        \$token = \$null
        while (\$token -eq \$null) {
            \$context = \$listener.GetContext()
            \$request = \$context.Request
            \$response = \$context.Response
            if (\$request.Url.PathAndQuery -match 'access_token=([^&]+)') {
                \$token = \$matches[1]
            }
            \$buffer = [System.Text.Encoding]::UTF8.GetBytes(\$landingPage)
            \$response.ContentLength64 = \$buffer.Length
            \$response.OutputStream.Write(\$buffer, 0, \$buffer.Length)
            \$response.OutputStream.Close()
        }
        \$listener.Stop()
        Write-Output \$token
    "
}

# Start server using netcat (Unix/macOS/Linux only)
_start_nc_server() {
    local port="$1" landing_page="$2" token="" request=""
    [[ "$OSTYPE" == msys || "$OSTYPE" == win32 || "$OSTYPE" == cygwin ]] && return 1

    msg "$CYAN" "Starting netcat server for OAuth callback (port: $port)" >&2

    # Build HTTP response (serve landing page for all requests)
    local response
    response=$(printf "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\nContent-Length: ${#landing_page}\r\n\r\n%s" "$landing_page")

    # OAuth flow: loop until we receive token via XHR callback
    # JavaScript in landing page retries if connection fails
    while [ -z "$token" ]; do
        if [[ "$OSTYPE" == darwin* ]]; then
            request=$(echo -e "$response" | nc -l "$port" 2>/dev/null) || true
        else
            request=$(echo -e "$response" | nc -l -p "$port" -q 1 2>/dev/null) || true
        fi
        [[ "$request" =~ access_token=([^&[:space:]]+) ]] && token="${BASH_REMATCH[1]}"
    done
    echo "$token"
}

# Start OAuth callback server (auto-selects best method)
_start_oauth_server() {
    local port="$1"
    local landing_page="$2"
    local oauth_url="$3"

    landing_page="${landing_page//PORT/$port}"
    _open_browser "$oauth_url" || warn "Please open the URL manually" >&2

    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
        if type -p powershell.exe &> /dev/null || type -p pwsh.exe &> /dev/null || \
           which powershell.exe &> /dev/null || which pwsh.exe &> /dev/null || \
           [[ -f /c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe ]]; then
            _start_powershell_server "$port" "$landing_page"
        elif type -p python3 &> /dev/null || type -p python.exe &> /dev/null || \
             which python3 &> /dev/null || which python.exe &> /dev/null; then
            _start_python_server "$port" "$landing_page"
        else
            msg "$RED" "Neither PowerShell nor Python 3 is available" >&2
            return 1
        fi
    else
        # Prefer nc (lightweight), fallback to Python
        if command -v nc &> /dev/null; then
            _start_nc_server "$port" "$landing_page"
        elif command -v python3 &> /dev/null; then
            _start_python_server "$port" "$landing_page"
        else
            msg "$RED" "Neither netcat nor Python 3 is available" >&2
            return 1
        fi
    fi
}

#==============================================================================
# SECTION 7: Authentication Functions (Public)
#==============================================================================

# Get Linode API token (env → linode-cli → OAuth)
# Usage: get_linode_token [silent]
# Returns: Token string on stdout
# Sets: LINODE_PROFILE_USERNAME, LINODE_PROFILE_EMAIL (exported)
get_linode_token() {
    local silent="${1:-false}"
    local token profile token_source

    # Check environment variable first
    if [ -n "${LINODE_TOKEN:-}" ]; then
        token="$LINODE_TOKEN"
        token_source="environment variable"
    # Try to get token from linode-cli config (silent, no messages)
    elif token=$(extract_linodecli_token true 2>/dev/null || true); [ -n "$token" ]; then
        token_source="linode-cli config"
    # Fallback to OAuth (allow messages to stderr based on silent flag)
    elif token=$(extract_oauth_token "$silent" || true); [ -n "$token" ]; then
        token_source="OAuth"
    else
        return 1
    fi

    # Validate token and set globals
    profile=$(get_profile "$token") || return 1
    LINODE_PROFILE_USERNAME=$(echo "$profile" | jq -r ".username // empty")
    LINODE_PROFILE_EMAIL=$(echo "$profile" | jq -r ".email // empty")
    export LINODE_PROFILE_USERNAME LINODE_PROFILE_EMAIL
    [ -n "$LINODE_PROFILE_USERNAME" ] || return 1

    # Show success message
    if [ "$silent" = false ]; then
        echo "" >&2
        msg "$GREEN" "========================================" >&2
        msg "$GREEN" "Authentication Successful" >&2
        msg "$GREEN" "========================================" >&2
        echo "" >&2
        msg "$CYAN" "Token source: ${token_source}" >&2
        msg "$CYAN" "Username: ${LINODE_PROFILE_USERNAME}" >&2
        echo "" >&2
    fi

    echo "$token"
}

# Extract and validate token from linode-cli configuration or environment
# Returns: Token string on stdout, exits 1 on error
extract_linodecli_token() {
    # Priority 1: Environment variable
    local token="${LINODE_CLI_TOKEN:-}"

    # Priority 2: Config file
    if [ -z "$token" ]; then
        local config="$(_find_config_file)"
        [ -f "$config" ] || return 1
        local user="$(_get_ini_value "$config" "DEFAULT" "default-user")"
        [ -n "$user" ] || return 1
        token="$(_get_ini_value "$config" "$user" "token")"
        [ -n "$token" ] || return 1
    fi

    # Validate token via API
    get_profile "$token" >/dev/null || return 1

    echo "$token"
}

# Extract token via OAuth flow
# Usage: extract_oauth_token [silent]
# Returns: Token string on stdout
extract_oauth_token() {
    local silent="${1:-false}"

    _check_oauth_dependencies || return 1

    if [ "$silent" = false ]; then
        echo -e "Starting Linode OAuth authentication..." >&2
    fi

    local port
    port=$(_find_available_port)
    if [ -z "$port" ]; then
        msg "$RED" "Could not find an available port" >&2
        return 1
    fi

    local landing_page
    landing_page=$(_create_landing_page "$port")
    local oauth_url="${OAUTH_LOGIN_URL}?client_id=${OAUTH_CLIENT_ID}&response_type=token&scopes=*&redirect_uri=http://localhost:${port}"

    if [ "$silent" = false ]; then
        echo "" >&2
        success "Opening browser. Please login with your Linode credential." >&2
        echo "" >&2
        sleep 3
        echo "If the browser doesn't open automatically, visit:" >&2
        echo "" >&2
        echo "$oauth_url" >&2
        echo "" >&2
        echo "Waiting for OAuth callback..." >&2
    fi

    local token
    token=$(_start_oauth_server "$port" "$landing_page" "$oauth_url")

    if [ -z "$token" ]; then
        msg "$RED" "Failed to receive OAuth token" >&2
        return 1
    fi

    if [ "$silent" = false ]; then
        echo "OAuth callback received" >&2
        echo "Validating token..." >&2
    fi

    # Validate token
    local profile username
    profile=$(get_profile "$token") || {
        msg "$RED" "Token validation failed" >&2
        return 1
    }

    username=$(echo "$profile" | jq -r ".username // empty")
    if [ -z "$username" ]; then
        msg "$RED" "Could not get username" >&2
        return 1
    fi

    echo "$token"
}

#==============================================================================
# SECTION 8: API Functions (Public)
#==============================================================================

# Make authenticated Linode API call
# Usage: linode_api_call <endpoint> <token> [method] [json_payload]
linode_api_call() {
    local endpoint="$1"
    local token="$2"
    local method="${3:-GET}"
    local payload="${4:-}"

    local curl_args=(
        -s
        -X "$method"
        -H "Authorization: Bearer ${token}"
        -H "Content-Type: application/json"
    )

    if [ -n "$payload" ]; then
        curl_args+=(-d "$payload")
    fi

    curl "${curl_args[@]}" "${API_BASE}${endpoint}"
}

# Get user profile information
# Usage: get_profile <token>
# Returns: JSON profile data
# Sets: LINODE_PROFILE_USERNAME, LINODE_PROFILE_EMAIL (global exported variables)
get_profile() {
    local token="$1"
    local response

    response=$(linode_api_call "/profile" "$token")

    # Validate response
    if ! echo "$response" | jq -e ".username" >/dev/null 2>&1; then
        return 1
    fi

    echo "$response"
}

# Get GPU availability data (returns JSON)
# Usage: get_gpu_availability [token]
# If token not provided, will attempt to get one
get_gpu_availability() {
    local token="${1:-}"

    if [ -z "$token" ]; then
        token=$(get_linode_token true) || {
            msg "$RED" "❌ Failed to get API token" >&2
            return 1
        }
    fi

    local temp_dir="${TMPDIR:-/tmp}"

    # Fetch pages in parallel
    for page in 1 2 3 4; do
        linode_api_call "/regions/availability?page_size=500&page=${page}" "$token" > "${temp_dir}/avail_page_${page}.json" &
    done
    linode_api_call "/linode/types" "$token" > "${temp_dir}/types.json" &
    linode_api_call "/regions" "$token" > "${temp_dir}/regions.json" &
    wait

    # Verify temp files
    for file in "${temp_dir}/avail_page_"{1,2,3,4}".json" "${temp_dir}/types.json" "${temp_dir}/regions.json"; do
        if [ ! -f "$file" ]; then
            msg "$RED" "❌ Failed to fetch data from API" >&2
            return 1
        fi
    done

    # Combine availability pages into temp file (avoids "Argument list too long" on Git Bash/Windows)
    jq -n -c '{data: [inputs.data[]] | unique}' "${temp_dir}/avail_page_"{1,2,3,4}".json" > "${temp_dir}/availability.json" || {
        msg "$RED" "❌ Failed to process availability data" >&2
        return 1
    }

    # Extract RTX4000 types to temp file
    jq -c '
        [.data[] | select(.id | startswith("g2-gpu-rtx4000")) |
        {
            id: .id,
            label: .label,
            hourly: .price.hourly,
            monthly: .price.monthly,
            vcpus: .vcpus,
            memory: .memory,
            gpus: .gpus,
            sort_gpu: (.id | capture("a(?<gpu>[0-9]+)").gpu | tonumber),
            sort_size: (if (.id | endswith("-s")) then 1
                       elif (.id | endswith("-m")) then 2
                       elif (.id | endswith("-l")) then 3
                       elif (.id | endswith("-xl")) then 4
                       elif (.id | endswith("-hs")) then 5
                       else 9 end)
        }] | sort_by(.sort_gpu, .sort_size)
    ' "${temp_dir}/types.json" > "${temp_dir}/rtx4000_types.json"

    local rtx4000_types
    rtx4000_types=$(cat "${temp_dir}/rtx4000_types.json")

    if [ "$rtx4000_types" = "[]" ]; then
        rm -f "${temp_dir}/avail_page_"{1,2,3,4}".json" "${temp_dir}/types.json" "${temp_dir}/regions.json" "${temp_dir}/availability.json" "${temp_dir}/rtx4000_types.json"
        msg "$RED" "❌ No RTX4000 instances found" >&2
        return 1
    fi

    # Output JSON using --slurpfile to read from files (avoids "Argument list too long" on Git Bash/Windows)
    jq -n -c \
        --slurpfile availability "${temp_dir}/availability.json" \
        --slurpfile regions "${temp_dir}/regions.json" \
        --slurpfile types "${temp_dir}/rtx4000_types.json" \
        '{
            instance_types: ($types[0] | map(del(.sort_gpu, .sort_size))),
            regions: ($regions[0].data | sort_by(.id) | map(
                . as $region |
                {
                    id: $region.id,
                    label: $region.label,
                    instance_types: [
                        $availability[0].data[] |
                        select(.region == $region.id and .plan != null and (.plan | startswith("g2-gpu-rtx4000")) and .available == true) |
                        .plan
                    ] | unique | sort
                }
            ) | map(select(.instance_types | length > 0)))
        }'

    # Clean up temp files
    rm -f "${temp_dir}/avail_page_"{1,2,3,4}".json" "${temp_dir}/types.json" "${temp_dir}/regions.json" "${temp_dir}/availability.json" "${temp_dir}/rtx4000_types.json"
}

# Get available regions from GPU data
# Usage: get_available_regions <gpu_data_json> <display_array_name> <data_array_name>
# Parameters:
#   gpu_data_json      - JSON from get_gpu_availability
#   display_array_name - Name of array to store formatted display strings (for ask_selection)
#   data_array_name    - Name of array to store raw data "region_id|region_label|instance_types"
# Example:
#   get_available_regions "$GPU_DATA" REGION_DISPLAY REGION_DATA
#   ask_selection "Select region" REGION_DISPLAY 1 sel_idx
#   IFS='|' read -r region_id region_label available_instance_types <<< "${REGION_DATA[$((sel_idx-1))]}"
get_available_regions() {
    local gpu_data="$1"
    local display_array_name="$2"
    local data_array_name="$3"

    if [ -z "$gpu_data" ]; then
        msg "$RED" "Error: GPU data is required" >&2
        return 1
    fi

    if [ -z "$display_array_name" ] || [ -z "$data_array_name" ]; then
        msg "$RED" "Error: display_array_name and data_array_name are required" >&2
        return 1
    fi

    # Clear the arrays
    eval "$display_array_name=()"
    eval "$data_array_name=()"

    # Parse regions and build arrays
    local raw_data
    raw_data=$(echo "$gpu_data" | jq -r '.regions[] | "\(.id)|\(.label)|\(.instance_types | join(","))"')

    while IFS= read -r line; do
        IFS='|' read -r region_id region_label types <<< "$line"
        # Format: "region_id (12 chars) region_label" for display
        local formatted_option
        printf -v formatted_option "%-12s %s" "$region_id" "$region_label"
        eval "$display_array_name+=(\"\$formatted_option\")"
        eval "$data_array_name+=(\"\$line\")"
    done <<< "$raw_data"
}

# Get GPU instance type details for selection menu
# Usage: get_gpu_details <gpu_data_json> <available_types_csv> <default_type> <display_array_name> <data_array_name> <default_index_var>
# Parameters:
#   gpu_data_json       - JSON from get_gpu_availability
#   available_types_csv - Comma-separated list of available instance types for the region
#   default_type        - Default instance type ID (e.g., "g2-gpu-rtx4000a1-s")
#   display_array_name  - Name of array to store formatted display strings (for ask_selection)
#   data_array_name     - Name of array to store raw JSON data for each type
#   default_index_var   - Name of variable to store the default index (1-based)
# Example:
#   get_gpu_details "$GPU_DATA" "$available_instance_types" "g2-gpu-rtx4000a1-s" TYPE_DISPLAY TYPE_DATA default_idx
#   ask_selection "Select instance type" TYPE_DISPLAY "$default_idx" sel_idx
#   selected_type=$(echo "${TYPE_DATA[$((sel_idx-1))]}" | jq -r '.id')
get_gpu_details() {
    local gpu_data="$1"
    local available_types="$2"
    local default_type="${3:-}"
    local display_array_name="$4"
    local data_array_name="$5"
    local default_index_var="$6"

    if [ -z "$gpu_data" ]; then
        msg "$RED" "Error: GPU data is required" >&2
        return 1
    fi

    if [ -z "$display_array_name" ] || [ -z "$data_array_name" ] || [ -z "$default_index_var" ]; then
        msg "$RED" "Error: display_array_name, data_array_name, and default_index_var are required" >&2
        return 1
    fi

    # Clear the arrays and default index
    eval "$display_array_name=()"
    eval "$data_array_name=()"
    eval "$default_index_var=''"

    # Process each instance type
    local idx=0
    while IFS= read -r type_data; do
        local type_id
        type_id=$(echo "$type_data" | jq -r '.id')

        # Skip if not in available types list
        echo "$available_types" | grep -q "$type_id" || continue

        # Skip g2-gpu-rtx4000a2-hs (label too long for display)
        [ "$type_id" = "g2-gpu-rtx4000a2-hs" ] && continue

        # Store raw data (escape single quotes in JSON for eval)
        local escaped_data="${type_data//\'/\'\\\'\'}"
        eval "$data_array_name+=('$escaped_data')"

        # Format display string
        local id lbl vcpus mem hr mo
        IFS=$'\t' read -r id lbl vcpus mem hr mo < <(echo "$type_data" | jq -r '[.id, .label, .vcpus, (.memory/1024|floor), .hourly, .monthly] | @tsv')

        local formatted_option
        printf -v formatted_option "%-20s %-25s ${CYAN}%d vCPUs, %dGB RAM - \$%s/hr (\$%s/mo)${NC}" "$id" "$lbl" "$vcpus" "$mem" "$hr" "$mo"
        eval "$display_array_name+=(\"\$formatted_option\")"

        idx=$((idx + 1))

        # Set default index if this matches default_type
        if [ -n "$default_type" ] && [ "$id" = "$default_type" ]; then
            eval "$default_index_var=$idx"
        fi
    done < <(echo "$gpu_data" | jq -c '.instance_types[]')
}

# Create a Linode instance with cloud-init
# Usage: create_instance <token> <label> <region> <type> <image> <root_pass> <ssh_key> <user_data_base64> [tags]
# Parameters:
#   tags - Optional: JSON array string like '["tag1","tag2"]', defaults to []
# Returns: JSON response from API
create_instance() {
    local token="$1"
    local label="$2"
    local region="$3"
    local type="$4"
    local image="$5"
    local root_pass="$6"
    local ssh_key="$7"
    local user_data_base64="$8"
    local tags="${9:-[]}"

    local payload
    payload=$(jq -n \
        --arg label "$label" \
        --arg region "$region" \
        --arg type "$type" \
        --arg image "$image" \
        --arg pass "$root_pass" \
        --arg userdata "$user_data_base64" \
        --arg sshkey "$ssh_key" \
        --argjson tags "$tags" \
        '{
            label: $label,
            region: $region,
            type: $type,
            image: $image,
            root_pass: $pass,
            metadata: {user_data: $userdata},
            authorized_keys: [$sshkey],
            tags: $tags,
            booted: true,
            backups_enabled: false,
            private_ip: false
        }')

    linode_api_call "/linode/instances" "$token" "POST" "$payload"
}

# Delete a Linode instance
# Usage: delete_instance <token> <instance_id>
delete_instance() {
    local token="$1"
    local instance_id="$2"

    linode_api_call "/linode/instances/${instance_id}" "$token" "DELETE"
}


# Create a Block Storage Volume
# Usage: create_volume <token> <label> <region> [size] [linode_id] [config_id] [encryption] [tags]
# Parameters:
#   token      - Linode API token (required)
#   label      - Volume name, 1-32 chars, alphanumeric/hyphens/underscores (required)
#   region     - Region ID (required if linode_id not provided)
#   size       - Size in GB, defaults to 20
#   linode_id  - Linode ID to attach volume to (optional)
#   config_id  - Config profile ID for attachment (optional, requires linode_id)
#   encryption - "enabled" or "disabled", defaults to "disabled"
#   tags       - Comma-separated list of tags (optional)
# Returns: JSON response from API
# Example:
#   create_volume "$TOKEN" "my-volume" "us-iad" 100
#   create_volume "$TOKEN" "my-volume" "" 50 12345
create_volume() {
    local token="$1"
    local label="$2"
    local region="${3:-}"
    local size="${4:-20}"
    local linode_id="${5:-}"
    local config_id="${6:-}"
    local encryption="${7:-disabled}"
    local tags="${8:-}"

    # Validate required parameters
    if [ -z "$token" ]; then
        msg "$RED" "Error: token is required" >&2
        return 1
    fi

    if [ -z "$label" ]; then
        msg "$RED" "Error: label is required" >&2
        return 1
    fi

    # Validate label format (1-32 chars, alphanumeric, hyphens, underscores)
    if [[ ! "$label" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]{0,31}$ ]]; then
        msg "$RED" "Error: label must be 1-32 characters, alphanumeric with hyphens/underscores" >&2
        return 1
    fi

    # Either region or linode_id must be provided
    if [ -z "$region" ] && [ -z "$linode_id" ]; then
        msg "$RED" "Error: region is required when linode_id is not provided" >&2
        return 1
    fi

    # config_id requires linode_id
    if [ -n "$config_id" ] && [ -z "$linode_id" ]; then
        msg "$RED" "Error: config_id requires linode_id" >&2
        return 1
    fi

    # Build JSON payload
    local payload
    payload=$(jq -n \
        --arg label "$label" \
        --arg size "$size" \
        --arg encryption "$encryption" \
        '{
            label: $label,
            size: ($size | tonumber),
            encryption: $encryption
        }')

    # Add optional fields
    if [ -n "$region" ]; then
        payload=$(echo "$payload" | jq --arg region "$region" '. + {region: $region}')
    fi

    if [ -n "$linode_id" ]; then
        payload=$(echo "$payload" | jq --arg linode_id "$linode_id" '. + {linode_id: ($linode_id | tonumber)}')
    fi

    if [ -n "$config_id" ]; then
        payload=$(echo "$payload" | jq --arg config_id "$config_id" '. + {config_id: ($config_id | tonumber)}')
    fi

    if [ -n "$tags" ]; then
        # Convert comma-separated tags to JSON array
        payload=$(echo "$payload" | jq --arg tags "$tags" '. + {tags: ($tags | split(",") | map(gsub("^\\s+|\\s+$"; "")))}')
    fi

    linode_api_call "/volumes" "$token" "POST" "$payload"
}

#==============================================================================
# SECTION 9: Validation Functions (Public)
#==============================================================================

# Validate instance label format
# Usage: validate_instance_label <label>
# Returns: 0 if valid, 1 with error message if invalid
validate_instance_label() {
    local label="$1"
    if [[ ! "$label" =~ ^[a-zA-Z0-9]([a-zA-Z0-9._-]*[a-zA-Z0-9])?$ ]]; then
        echo "Label must start/end with alphanumeric, use only: a-z A-Z 0-9 _ - ."
        return 1
    fi
    if [[ "$label" =~ --|__|\.\. ]]; then
        echo "Label cannot contain consecutive -- __ or .."
        return 1
    fi
    return 0
}

# Validate root password requirements
# Usage: validate_root_password <password>
# Returns: 0 if valid, 1 if invalid
validate_root_password() {
    local pwd="$1"
    [[ ${#pwd} -ge 11 && "$pwd" =~ [A-Z] && "$pwd" =~ [a-z] && "$pwd" =~ [0-9] && "$pwd" =~ [^A-Za-z0-9] ]]
}

# Generate random root password
# Usage: generate_root_password
# Returns: 15-char password with upper, lower, numbers, special chars
generate_root_password() {
    local chars='A-Za-z0-9!@#$%^&*()_+-='
    LC_ALL=C tr -dc "$chars" < /dev/urandom | head -c 15 2>/dev/null || true
}

#==============================================================================
# SECTION 10: SSH Key (Public)
#==============================================================================

# Get SSH public keys from ~/.ssh directory
# Usage: get_ssh_keys <display_array_name> <path_array_name> [include_auto_generate]
# Parameters:
#   display_array_name   - Name of array to store formatted display strings (for ask_selection)
#   path_array_name      - Name of array to store full paths to key files
#   include_auto_generate - If "true", adds auto-generate option at end (default: true)
# Example:
#   get_ssh_keys SSH_DISPLAY SSH_PATHS
#   ask_selection "Select SSH key" SSH_DISPLAY "" key_choice
#   if [ "$key_choice" -le ${#SSH_PATHS[@]} ]; then
#       SSH_PUBLIC_KEY=$(cat "${SSH_PATHS[$((key_choice-1))]}")
#   else
#       # User selected auto-generate
#   fi
get_ssh_keys() {
    local display_array_name="$1"
    local path_array_name="$2"
    local include_auto_generate="${3:-true}"

    # Clear the arrays
    eval "$display_array_name=()"
    eval "$path_array_name=()"

    # Find SSH public keys
    local key_files=()
    while IFS= read -r key; do
        [ -n "$key" ] && key_files+=("$key")
    done < <(find "$HOME/.ssh" -maxdepth 1 -name "*.pub" -type f 2>/dev/null | sort)

    # Build display and path arrays
    if [ ${#key_files[@]} -gt 0 ]; then
        for key_path in "${key_files[@]}"; do
            local key_basename key_preview formatted_option
            key_basename="$(basename "$key_path")"
            key_preview="$(head -c 60 "$key_path" 2>/dev/null || true)"
            printf -v formatted_option "%-30s %s..." "$key_basename" "$key_preview"
            eval "$display_array_name+=(\"\$formatted_option\")"
            eval "$path_array_name+=(\"\$key_path\")"
        done
    fi

    # Add auto-generate option if requested
    if [ "$include_auto_generate" = "true" ]; then
        eval "$display_array_name+=(\"\${YELLOW}Auto-generate new SSH key pair\${NC}\")"
    fi
}

# Generate new SSH key pair
# Usage: generate_ssh_key <key_path> [comment]
# Parameters:
#   key_path - Path for the new key (without .pub extension)
#   comment  - Optional comment for the key (default: "linode-quickstart")
# Returns: 0 on success, 1 on failure
# Outputs: Public key content on stdout
# Example:
#   NEW_KEY_PATH="$HOME/.ssh/linode-myinstance-$(date +%s)"
#   SSH_PUBLIC_KEY=$(generate_ssh_key "$NEW_KEY_PATH" "my-instance-key")
generate_ssh_key() {
    local key_path="$1"
    local comment="${2:-linode-quickstart}"

    # Generate key pair (Ed25519, no passphrase)
    if ! ssh-keygen -t ed25519 -f "$key_path" -N "" -C "$comment" > /dev/null 2>&1; then
        msg "$RED" "❌ Failed to generate SSH key" >&2
        return 1
    fi

    # Set proper permissions
    chmod 600 "$key_path" 2>/dev/null || true
    chmod 644 "${key_path}.pub" 2>/dev/null || true

    # Output public key content
    cat "${key_path}.pub"
}

