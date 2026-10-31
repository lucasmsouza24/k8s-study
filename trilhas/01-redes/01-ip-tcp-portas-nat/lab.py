def convert_decimal_to_bit(dec_value: int):
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

    print(f'{dec_value} = {bin_value}')

total_values = 65535
for i in range(0, total_values + 1):
    convert_decimal_to_bit(i)
