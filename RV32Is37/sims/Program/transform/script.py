import os
import re
import sys


def transform(src: str, dst: str):
    if not os.path.exists(os.path.dirname(dst)):
        os.makedirs(os.path.dirname(dst))

    with open(src, 'r') as file_src:
        with open(dst, 'w') as file_dst:
            try:
                cmd = file_src.readline()
                while cmd:
                    if re.match('[0-9a-f]{8}:\t[0-9a-f]{4,8} +\t.+', cmd):
                        sub_str = re.search('([0-9a-f]{8}):\t([0-9a-f]{4,8}) +\t(.*)', cmd)
                        address = (int(sub_str.group(1), base=16) - 0x80000000) >> 2
                        instruction = int(sub_str.group(2), base=16)
                        file_dst.write('@%08x %08x        // %s\n' % (address, instruction, sub_str.group(3)))
                    elif re.match('[^ \t\n].*', cmd):
                        file_dst.write('// ' + cmd)
                    else:
                        file_dst.write(cmd)
                    cmd = file_src.readline()
            except EOFError:
                print(src + 'converts to ' + dst)
            finally:
                file_src.close()
                file_dst.close()


if __name__ == '__main__':
    if len(sys.argv) == 3:
        # Print Source & Destination Directories for Transformation.
        print('Src Directory: ' + sys.argv[1])
        print('Dst Directory: ' + sys.argv[2])

        # Check If the Source Directory Exists
        assert os.path.exists(sys.argv[1])
        # Check Dump Files in all the Directories
        dirs = os.listdir(sys.argv[1])
        dump = []
        while len(dirs) > 0:
            part = dirs[0]

            full = sys.argv[1] + '/' + part
            if os.path.isdir(full):
                for item in os.listdir(full):
                    path = full + '/' + item
                    if os.path.isdir(path):
                        dirs.append(part + '/' + item)
                    else:
                        file = os.path.splitext(path)
                        file_base, file_type = file
                        if file_type == '.dump':
                            dump.append(part + '/' + item)
            else:
                file = os.path.splitext(full)
                file_base, file_type = file
                if file_type == '.dump':
                    dump.append(part)

            dirs.remove(dirs[0])
        print(dump)

        # Check whether the Destination Directory Exists.
        # If it exists, the script will delete it.
        if os.path.exists(sys.argv[2]):
            os.remove(sys.argv[2])
        # Remake Directories
        os.makedirs(sys.argv[2])

        for name in dump:
            file = os.path.splitext(name)
            file_base, file_type = file
            transform(sys.argv[1] + '/' + file_base + '.dump', sys.argv[2] + '/' + file_base + '.mem')
    else:
        print('Correct Format: python script.py <src_dir> <dst_dir>')
