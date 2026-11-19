CC      ?= cc
CFLAGS  ?= -Wall -Wextra -std=c11 -O2
TARGET   = lsh
SRC      = shell.c

.PHONY: all run clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET) $(TARGET).exe
