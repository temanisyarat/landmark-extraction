.PHONY: all venv augment extract analyze reformat

VENV_DIR = .venv

all: venv augment extract analyze reformat

venv:
	python -m venv $(VENV_DIR)
	$(VENV_DIR)/bin/pip install --upgrade pip
	$(VENV_DIR)/bin/pip install -r requirements.txt

augment: venv
	./augmentation.sh

extract: venv 
	./extract.sh $(VENV_DIR)

analyze: venv 
	./analyze.sh $(VENV_DIR)

reformat:
	./reformat.sh
