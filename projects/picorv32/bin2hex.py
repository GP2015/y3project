import sys

bin_name = sys.argv[1]
hex_name = sys.argv[2]

data = open(bin_name, "rb").read()
data += b"\x00" * (-len(data) % 4)

with open(hex_name, "w") as f:
    for i in range(0, len(data), 4):
        word = int.from_bytes(data[i:i+4], "little")
        f.write(f"{word:08x}\n")
