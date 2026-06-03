.PHONY: all venv augment extract analyze reformat

VENV_DIR = .venv

all: venv augment extract analyze

venv:
	python -m venv $(VENV_DIR)
	$(VENV_DIR)/bin/pip install --upgrade pip
	$(VENV_DIR)/bin/pip install -r requirements.txt

augment: venv
	./augmentation.sh

extract: augment
	./extract.sh $(VENV_DIR)

analze: extract
	./analyze.sh $(VENV_DIR)

reformat: extract
	./reformat.sh
