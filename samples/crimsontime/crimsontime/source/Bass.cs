using System;
using System.Runtime.InteropServices;

namespace Bass
{
    public static class Bass
    {
        [DllImport("bass.dll", CallingConvention = CallingConvention.StdCall, EntryPoint = "BASS_Init")]
	    [PreserveSig]
        public static extern bool BASS_Init(int device, UInt16 freq, UInt16 flags, IntPtr win, IntPtr clsid);

        [DllImport("bass.dll", CallingConvention = CallingConvention.StdCall, EntryPoint = "BASS_Free")]
	    [PreserveSig]
        public static extern bool BASS_Free();

        [DllImport("bass.dll", CallingConvention = CallingConvention.StdCall, EntryPoint = "BASS_Stop")]
	    [PreserveSig]
        public static extern bool BASS_Stop();

        [DllImport("bass.dll", CallingConvention = CallingConvention.StdCall, EntryPoint = "BASS_Start")]
	    [PreserveSig]
        public static extern bool BASS_Start();

        [DllImport("bass.dll", CallingConvention = CallingConvention.StdCall, EntryPoint = "BASS_SampleLoad", CharSet = CharSet.Ansi)]
	    [PreserveSig]
	    public static extern UInt32 BASS_SampleLoad(bool mem, string f, UInt16 offset, UInt16 length, UInt16 max, UInt16 flags);
        
        [DllImport("bass.dll", CallingConvention = CallingConvention.StdCall, EntryPoint = "BASS_SamplePlay")]
        [PreserveSig]
        public static extern bool BASS_SamplePlay(UInt32 UInt32);

        [DllImport("bass.dll", CallingConvention = CallingConvention.StdCall, EntryPoint = "BASS_StreamPlay")]
	    [PreserveSig]
	    public static extern bool BASS_StreamPlay(IntPtr UInt32, bool flush, UInt16 flags);

        [DllImport("bass.dll", CallingConvention = CallingConvention.StdCall, EntryPoint = "BASS_StreamCreateFile")]
	    [PreserveSig]
	    public static extern UInt32 BASS_StreamPlay(bool mem, IntPtr f, UInt16 offset, UInt16 length, UInt16 flags);
    }

}