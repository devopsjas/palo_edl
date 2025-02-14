import sys

def validate_edl(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()
        for line in lines:
            if not line.strip():
                continue
            if not line.startswith("http") and not line.replace('.', '').isdigit():
                print(f"Invalid entry in {file_path}: {line}")
                sys.exit(1)
    print("EDL File is valid!")

if __name__ == "__main__":
    validate_edl("ansible/edl-file.txt")
