def convert_decimal_to_bin(dec_value: int):
    bin_values = []
    value = dec_value

    if dec_value > 1:
        while value > 1:
            bin_values.append(str(value % 2))
            value = value // 2
        bin_values.append('1')

        bin_value = ''
        while len(bin_values) > 0:
            bin_value += bin_values.pop()
    else:
        bin_value = str(dec_value)

    return bin_value

# total_values = 65535
# for i in range(0, total_values + 1):
#     convert_decimal_to_bin(i)

def convert_ip_to_binary(ip_decimal: str):
    splited_ip = ip_decimal.split('.')
    ip_bin = ''
    for i in range(0, len(splited_ip)):
        ip_bin += convert_decimal_to_bin(int(splited_ip[i]))
        ip_bin += '.' if i != len(splited_ip) - 1 else ''
    return ip_bin

#convert_decimal_to_bin(192)
#print(convert_ip_to_binary('192.168.3.4'))
print(convert_ip_to_binary('206.25.231.84'))

#print(convert_decimal_to_bin(4))
