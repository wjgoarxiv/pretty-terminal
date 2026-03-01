<p align="center">
  <img src="cover.png" alt="pretty-terminal" width="100%">
</p>

# pretty-terminal

터미널을 아름답게 만드는 한 줄 명령어. macOS, Windows, Linux 모두 지원합니다.

> [English](README.md) | **한국어**

## 주요 기능

- **JetBrainsMono Nerd Font** — 아이콘을 지원하는 아름다운 고정폭 폰트 (한국어 사용자를 위한 D2CodingLigature Nerd Font Mono 선택 가능)
- **eza** — 아이콘과 트리 뷰를 지원하는 모던 파일 목록 도구
- **Oh My Zsh + Powerlevel10k** (macOS/Linux) — Git 상태를 표시하는 깔끔한 프롬프트
- **Oh My Posh** (Windows) — 테마를 지원하는 모던 셸 프롬프트

<p align="center">
  <img src="preview.png" alt="설치 전후 비교" width="100%">
</p>

## 빠른 시작

### LLM 사용 (권장)

Claude, ChatGPT 또는 다른 AI 어시스턴트에 아래 내용을 붙여넣으세요:

```
https://github.com/wjgoarxiv/pretty-terminal 을 홈 디렉토리에 클론하고 내 운영체제에 맞는 설치 스크립트를 실행해줘.
```

AI가 나머지를 자동으로 처리합니다.

### 직접 설치

**macOS / Linux:**
```bash
git clone https://github.com/wjgoarxiv/pretty-terminal.git ~/pretty-terminal
bash ~/pretty-terminal/install.sh
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/wjgoarxiv/pretty-terminal.git $HOME\pretty-terminal
& $HOME\pretty-terminal\install.ps1
```

설치 후 터미널을 재시작하세요.

## 설치 항목

| 구성 요소 | macOS | Linux | Windows |
|-----------|:-----:|:-----:|:-------:|
| JetBrainsMono Nerd Font | ✓ | ✓ | ✓ |
| eza (모던 ls) | ✓ | ✓ | ✓ |
| Oh My Zsh | ✓ | ✓ | — |
| Powerlevel10k | ✓ | ✓ | — |
| Oh My Posh | — | — | ✓ |

## 지원 터미널

- **macOS**: iTerm2, Ghostty (자동 설정), Terminal.app (AppleScript로 폰트 자동 적용). 기타 터미널은 환경설정에서 수동으로 폰트를 지정하세요.
- **Linux**: Ghostty (자동 설정 적용). GNOME Terminal, Konsole 등은 터미널 환경설정에서 JetBrainsMono Nerd Font를 수동으로 설정하세요.
- **Windows**: Windows Terminal (권장)

설치 스크립트가 OS를 자동 감지하여 호환되는 구성 요소를 설치합니다.

## 설치 옵션

설치 스크립트에 플래그를 추가하여 사용할 수 있습니다:

| 옵션 | 설명 |
|------|------|
| `--font-only` | Nerd Font만 설치하고 나머지는 건너뜁니다 |
| `--font d2coding` | JetBrainsMono 대신 D2CodingLigature Nerd Font Mono를 설치합니다 (한국어 지원) |
| `--no-theme` | 테마 및 셸 설정을 건너뜁니다 |
| `--uninstall` | 백업에서 원래 설정을 복원합니다 |

### macOS / Linux 예시:
```bash
bash ~/pretty-terminal/install.sh --font-only
bash ~/pretty-terminal/install.sh --font d2coding    # 한국어 폰트 사용
```

### Windows 예시:
```powershell
& $HOME\pretty-terminal\install.ps1 -FontOnly
& $HOME\pretty-terminal\install.ps1 -Font d2coding   # 한국어 폰트 사용
```

## 설치 과정 상세

### macOS / Linux

1. **JetBrainsMono Nerd Font 다운로드 및 설치** — `~/.local/share/fonts` (Linux) 또는 `~/Library/Fonts` (macOS)에 설치
2. **eza 설치** — 시스템 패키지 매니저를 통해 설치:
   - macOS: Homebrew (`brew install eza`)
   - Ubuntu/Debian: APT (커스텀 저장소)
   - Fedora/RHEL: DNF
   - Arch: Pacman
3. **Oh My Zsh 설치** (미설치 시)
4. **Powerlevel10k 테마 설치**
5. **기본 셸을 zsh로 설정**
6. **기존 셸 설정 백업** (`.zshrc`, `.bashrc` 등을 `.bak` 확장자로 저장)

### Windows

1. **JetBrainsMono Nerd Font 다운로드 및 설치** — 사용자 폰트 디렉토리에 설치
2. **Scoop 패키지 매니저 설치** (미설치 시)
3. **Scoop을 통해 eza 설치**
4. **Windows 레지스트리에 폰트 등록** — 시스템 전체에서 사용 가능

## 제거

원래 터미널 설정으로 복원하려면:

**macOS / Linux:**
```bash
bash ~/pretty-terminal/install.sh --uninstall
```

**Windows:**
```powershell
& $HOME\pretty-terminal\install.ps1 -Uninstall
```

백업된 설정 파일을 복원하고, 설치된 패키지를 제거합니다 (선택 시).

## 문제 해결

### 터미널에 폰트가 표시되지 않는 경우

1. 설치 후 **터미널을 재시작**하세요
2. 터미널 환경설정에서 **JetBrainsMono Nerd Font** (또는 `--font d2coding`으로 설치한 경우 D2CodingLigature Nerd Font Mono)를 선택하세요
3. **Windows**: 폰트 설치 후 Windows Terminal을 재시작하세요
4. **macOS Terminal.app**: 터미널 > 설정 > 프로파일 > 프로파일 선택 > 서체 옆 "변경..." 클릭 > "JetBrainsMono Nerd Font" 검색 (또는 `--font d2coding` 사용 시 "D2CodingLigature Nerd Font Mono")

### eza 명령어를 찾을 수 없는 경우

1. 설치 확인: `eza --version`
2. 누락된 경우 설치 스크립트를 다시 실행하세요
3. **macOS**: Homebrew가 설치되어 있는지 확인 (`brew --version`)
4. **Windows**: Scoop이 설치되어 있는지 확인 (`scoop --version`)

### install.sh 실행 권한 오류

bash로 직접 실행하세요:
```bash
bash ~/pretty-terminal/install.sh
```

또는 먼저 실행 권한을 부여하세요:
```bash
chmod +x ~/pretty-terminal/install.sh
bash ~/pretty-terminal/install.sh
```

## 커스터마이징

### eza 별칭

설치 후 다음 별칭을 사용할 수 있습니다:

```bash
ls   # eza --tree --icons --level=1
ll   # eza -la --icons
lt   # eza --tree --icons
la   # eza -a --icons
```

`~/.zshrc` (macOS/Linux) 또는 PowerShell 프로필 (Windows)을 편집하여 나만의 별칭을 추가하세요.

### Powerlevel10k 설정

Powerlevel10k 설정 마법사를 언제든 실행할 수 있습니다:

```bash
p10k configure
```

프롬프트를 커스터마이징하는 대화형 설정 마법사가 열립니다.

## 시스템 요구 사항

- **macOS**: 10.14 이상
- **Linux**: Ubuntu 18.04+, Fedora 32+, Arch 또는 호환 배포판
- **Windows**: Windows 10 21H2 이상 (Windows 11 권장)
- **Bash/Zsh** (macOS, Linux) 또는 **PowerShell 7+** (Windows)

## 기여하기

문제를 발견하셨거나 제안 사항이 있으신가요?

1. GitHub에서 기존 이슈를 확인하세요
2. OS와 터미널 정보를 포함하여 새 이슈를 등록하세요
3. `bash ~/pretty-terminal/install.sh` 또는 `& $HOME\pretty-terminal\install.ps1`의 출력을 첨부하세요

## 라이선스

MIT 라이선스 — 자세한 내용은 LICENSE 파일을 참조하세요.

---

**터미널을 아름답게 만들기 위해 ❤️으로 제작되었습니다.**
