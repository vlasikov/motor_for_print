Прошивка для Xilinx

sdram_ov5640_lcd.v  -- основной файл
считываем нажатие кнопок key1-key4
!!!!!!!!!!!if (counterAnilox<1000) begin //2000 small//300000 - very small speed

  smg_interface.v	- объявление подмодулей
    smg_control.v
    smg_encode_module.v - вывод цифр на индикатор
    smg_scan_module.v   - считывание цифр с индикатора
			
