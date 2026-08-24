#!/bin/bash

# Инициализируем переменные по умолчанию
VERBOSE=false
AGENT="opencode"

# Разбираем флаги перед основным аргументом
while [[ "$1" =~ ^- ]]; do
  case "$1" in
  -v | --verbose)
    VERBOSE=true
    shift
    ;;
  --agent)
    # Проверяем, передано ли значение для флага
    if [[ -z "$2" || "$2" =~ ^- ]]; then
      echo "Ошибка: флаг --agent требует указания значения (opencode или omp)"
      exit 1
    fi
    AGENT="$2"
    # Проверяем корректность значения агента
    if [[ "$AGENT" != "opencode" && "$AGENT" != "omp" ]]; then
      echo "Ошибка: неверное значение для --agent: '$AGENT'. Допустимы только 'opencode' или 'omp'."
      exit 1
    fi
    shift 2
    ;;
  *)
    echo "Ошибка: неизвестный флаг $1"
    echo "Использование: $0 [-v|--verbose] [--agent opencode|omp] <путь_к_файлу.txt>"
    exit 1
    ;;
  esac
done

# Проверяем, передан ли аргумент с файлом
if [ -z "$1" ]; then
  echo "Ошибка: Не указан файл с задачами!"
  echo "Использование: $0 [-v|--verbose] [--agent opencode|omp] <путь_к_файлу.txt>"
  exit 1
fi

TASK_FILE="$1"
LOG_FILE="progress.txt"

# Проверяем существование файла с задачами
if [ ! -f "$TASK_FILE" ]; then
  echo "Ошибка: Файл '$TASK_FILE' не найден!"
  exit 1
fi

# Получаем общее количество задач
TOTAL_TASKS=$(wc -l "$TASK_FILE" | awk '{print $1}')
# Инициализируем счетчик текущей задачи
CURRENT_TASK_NUM=1

# Получаем время начала выполнения всего скрипта
TOTAL_START=$(date +%s)

# Очищаем или создаем файл лога перед началом работы
echo "========= Начало: $(date) =========" >"$LOG_FILE"
echo "AI-агент: $AGENT" >>"$LOG_FILE"
echo "Количество задач: $TOTAL_TASKS" >>"$LOG_FILE"
echo "=======================================================" >>"$LOG_FILE"
echo >>"$LOG_FILE"

echo "==================================================="
echo "AI-агент: $AGENT"
echo "Количество задач: $TOTAL_TASKS"
echo -e "===================================================\n"

# Читаем файл, пока в нем есть строки
while [ -s "$TASK_FILE" ]; do
  # Всегда берем первую строку из файла
  IFS= read -r PROMPT <"$TASK_FILE"

  # Пропускаем пустые строки и удаляем их из файла
  if [ -z "$PROMPT" ]; then
    sed -i '1d' "$TASK_FILE"
    continue
  fi

  # Выводим инфо в терминал
  echo "---------------------------------------------------"
  echo "Задача $CURRENT_TASK_NUM из $TOTAL_TASKS: $PROMPT"
  echo "---------------------------------------------------"

  if [ "$VERBOSE" = true ]; then
    echo -e "\nВывод команды $AGENT:"
  fi

  # Временный файл для перехвата вывода команды агента
  TMP_OUTPUT=$(mktemp)

  # Формируем команду
  if [ "$AGENT" = "opencode" ]; then
    CMD=(opencode run "$PROMPT")
  elif [ "$AGENT" = "omp" ]; then
    CMD=(omp --print "$PROMPT")
  fi

  # Получаем время начала выполнения задачи в секундах (Unix Epoch)
  sec1=$(date +%s)

  # Запускаем команду в зависимости от флага VERBOSE
  if [ "$VERBOSE" = true ]; then
    # Дублируем вывод в терминал и во временный файл
    "${CMD[@]}" </dev/null 2>&1 | tee "$TMP_OUTPUT"
    STATUS=${PIPESTATUS}
  else
    # Перенаправляем вывод только во временный файл (скрываем из консоли)
    "${CMD[@]}" </dev/null >"$TMP_OUTPUT" 2>&1
    STATUS=$?
  fi

  # Получаем время окончания выполнения задачи в секундах (Unix Epoch)
  sec2=$(date +%s)

  # Считаем общую разницу в секундах
  diff=$((sec2 - sec1))

  # Раскладываем секунды на часы, минуты и секунды
  hours=$((diff / 3600))
  minutes=$(((diff % 3600) / 60))
  seconds=$((diff % 60))

  # Записываем результат выполнения в лог-файл
  {
    echo "-------------------------------------------------------"
    echo "Задача $CURRENT_TASK_NUM из $TOTAL_TASKS: $PROMPT"
    echo "-------------------------------------------------------"
    echo
    echo "Вывод команды $AGENT:"
    cat "$TMP_OUTPUT"
    echo
  } >>"$LOG_FILE"

  # Проверяем успешность выполнения
  if [ $STATUS -ne 0 ]; then
    echo -e "\n[ОШИБКА] Команда $AGENT завершилась неудачно со статусом $STATUS!" | tee -a "$LOG_FILE"
    echo "Выполнение скрипта прервано. Файл задач остановлен на текущей строке." | tee -a "$LOG_FILE"
    rm -f "$TMP_OUTPUT"
    exit $STATUS
  fi

  # Удаляем успешно выполненную задачу (первую строку) из файла tasks.txt
  sed -i '1d' "$TASK_FILE"

  # Пишем разделитель в лог и терминал, если всё успешно
  echo "Задача успешно выполнена и удалена из списка." >>"$LOG_FILE"
  echo "Время выполненения задачи: $hours ч., $minutes мин., $seconds сек." >>"$LOG_FILE"
  echo -e "-------------------------------------------------------\n" >>"$LOG_FILE"
  echo -e "\nЗадача успешно выполнена и удалена из списка."
  echo -e "Время выполнения задачи: $hours ч., $minutes мин., $seconds сек."
  echo -e "---------------------------------------------------\n"

  rm -f "$TMP_OUTPUT"

  # Увеличиваем счетчик текущей задачи на 1
  ((CURRENT_TASK_NUM++))
done

# Получаем время окончания работы всех задач
TOTAL_END=$(date +%s)
TOTAL_DIFF=$((TOTAL_END - TOTAL_START))

# Раскладываем общее время
t_hours=$((TOTAL_DIFF / 3600))
t_minutes=$(((TOTAL_DIFF % 3600) / 60))
t_seconds=$((TOTAL_DIFF % 60))

echo "==================================================="
echo "Задачи успешно выполнены за $t_hours ч. $t_minutes мин. $t_seconds сек."
echo "Лог сохранен в $LOG_FILE."
echo "==================================================="
echo "=======================================================" >>"$LOG_FILE"
echo "Задачи успешно выполнены за $t_hours ч. $t_minutes мин. $t_seconds сек." >>"$LOG_FILE"
echo "=======================================================" >>"$LOG_FILE"
