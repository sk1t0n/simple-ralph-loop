# simple-ralph-loop

Простой Ralph Loop для задач не связанных с программированием.

## Требования

1. **Git**. Установка:
  - `sudo apt install git` - Linux (Debian/Ubuntu)
  - `pkg update && pkg upgrade -y && pkg install git -y` - Termux
2. **AI-агент** (в Android устанавливать через [Core-Termux](https://devcorex-web.vercel.app/core-termux)). Поддерживаются следующие AI-агенты:
  - [OpenCode](https://opencode.ai/) - используется по умолчанию
  - [Oh My Pi (OMP)](https://omp.sh/) - задаётся через опцию `--agent omp`

## Использование

Пример запуска скрипта в Linux и Android ([Termux](https://devcorex-web.vercel.app/termux)):

```bash
# клонировать репозиторий и перейти в него
git clone https://github.com/sk1t0n/simple-ralph-loop.git
cd simple-ralph-loop

# сделать скрипт исполняемым в Linux
sudo chmod +x ralph.sh
# сделать скрипт исполняемым в Termux
chmod +x ralph.sh

# запустить скрипт с настройками по умолчанию
./ralph.sh tasks.txt
# или
make
# или
make run

# запустить скрипт в многословном режиме (показывать в консоли вывод команды AI-агента) и AI-агентом по умолчанию
./ralph.sh --verbose tasks.txt
# или
./ralph.sh -v tasks.txt
# или
make run_verbose

# запустить AI-агента OMP (Oh My Pi) вместо OpenCode, который используется по умолчанию
./ralph.sh --agent omp tasks.txt
```

Пример `tasks.txt`:

```txt
Напиши черновик делового письма.
Исправь ошибки и улучши стиль следующего текста: <TEXT>.
Сделай краткую выжимку (самари) для следующей статьи: <URL>.
```

Прогресс выполнения задач можно посмотреть в файле `progress.txt` c помощью команды `cat progress.txt`.
