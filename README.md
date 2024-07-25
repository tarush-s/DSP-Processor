# DSP PROCESSOR ON FPGA 
Hardware Used: 
    * FPGA: ARTY A7-100T Artix-7
    * MCU: SAMW 25 Microchip 

## Low-Pass Filter Specification:
<p>
    sampling frequency: 100 Hz

    0 Hz - 10 Hz
    gain = 1
    desired ripple = 5 dB
    actual ripple = 2.3133909166191504 dB

    20 Hz - 50 Hz
    gain = 0
    desired attenuation = -40 dB
    actual attenuation = -45.01618674525617 dB
</p>


<p> 15 Tap Filter impulse response: 

static double impulse response[FIR_FILTER_LENGTH] = {<br>
  -0.01259277478717816,<br>
  -0.02704833486706803,<br>
  -0.031157016036431583,<br>
  -0.003351666747179282,<br>
  0.06651710329324828,<br>
  0.1635643048779222,<br>
  0.249729473226146,<br>
  0.2842779082622769,<br>
  0.249729473226146,<br>
  0.1635643048779222,<br>
  0.06651710329324828,<br>
  -0.003351666747179282,<br>
  -0.031157016036431583,<br>
  -0.02704833486706803,<br>
  -0.01259277478717816<br>
};<br>

## Floating Point representation to fixed point representation: <br>

A 16-bit register stores the tap and 15-bit values for the fractional part. <br>

tap 0 = 2's compliment(-0.01259277478717816 * 32768) 	= 0xFE63<br>
tap 1 = 2's compliment(-0.02704833486706803 * 32768) 	= 0xFC8A<br>
tap 2 = 2's compliment(-0.031157016036431583 * 32768) 	= 0xFC03<br>
tap 3 = 2's compliment(-0.003351666747179282 * 32768) 	= 0xFF92<br>

tap 4 = (0.06651710329324828 * 32768)	= 0x0884<br>
tap 5 = (0.1635643048779222 * 32768) 	= 0x14F0<br>
tap 6 = (0.249729473226146 * 32768) 	= 0x1FF7<br>
tap 7 = (0.2842779082622769 * 32768) 	= 0x2463<br>
tap 8 = (0.249729473226146 * 32768) 	= 0x1FF7<br>
tap 9 = (0.1635643048779222 * 32768) 	= 0x14F0<br>
tap 10 = (0.06651710329324828 * 32768) 	= 0x0884<br>

tap 11 = 2's compliment(-0.003351666747179282 * 32768) 	= 0xFF92<br>
tap 12 = 2's compliment(-0.031157016036431583 * 32768) 	= 0xFC03<br>
tap 13 = 2's compliment(-0.02704833486706803 * 32768) 	= 0xFC8A<br>
tap 14 = 2's compliment(-0.01259277478717816 * 32768) 	= 0xFE63<br>
</p>
