import sys

if len(sys.argv) != 4:
    print(f'''Usage
{sys.argv[0]} {{file_to_decrypt}} {{decryption_key}} {{output_file}}
''')
    sys.exit(1)

# key: AdsipPewFlfkmll

def XORFile(f_path, encryption_key, o_path):
    with open(f_path, "rb") as file:
        file_contents = bytearray(file.read())

    key_length = len(encryption_key)
    for i in range(len(file_contents)):
        file_contents[i] ^= ord(encryption_key[i % key_length])

    with open(o_path, "wb") as file:
        file.write(file_contents)

if __name__ == "__main__":
        XORFile(sys.argv[1], sys.argv[2], sys.argv[3])
