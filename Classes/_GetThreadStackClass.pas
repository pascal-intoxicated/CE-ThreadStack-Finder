unit _GetThreadStackClass;

interface

uses
  Winapi.Windows, Winapi.TlHelp32, Winapi.PsAPI, System.SysUtils, System.Classes;

  procedure GetThreadStackPtrs(hProcess : THandle; ResultList : TStringList; ProcessId : DWORD);

type
  NTSTATUS        = ULONG;
  THREADINFOCLASS = DWORD;

  { http://undocumented.ntinternals.net/index.html?page=UserMode%2FStructures%2FTHREAD_BASIC_INFORMATION.html }
  THREAD_BASIC_INFORMATION = record
    ExitStatus     : Cardinal;
    TebBaseAddress : Pointer;
    ProcessId      : THandle;
    ThreadId       : THandle;
    AffinityMask   : ULONG;
    Priority       : LongInt;
    BasePriority   : LongInt;
  end;

  { https://www.nirsoft.net/kernel_struct/vista/NT_TIB.html }
  _NT_TIB = record
    ExceptionList        : Pointer;
    StackBase            : Pointer;
    StackLimit           : Pointer;
    SubSystemTib         : Pointer;
    FiberData            : Pointer;
    ArbitraryUserPointer : Pointer;
    Self                 : Pointer;
  end;

  function OpenThread(dwDesiredAcces : DWORD; blnheritHandle : Bool; dwThreadId : DWORD) : THandle; stdcall; external 'kernel32.dll';
  function NtQueryInformationThread(ThreadHandle : THandle; ThreadInformationClass : THREADINFOCLASS; ThreadInformation : Pointer; ThreadInformationLength : ULONG; ReturnLength : PULONG) : NTSTATUS; stdcall; external 'ntdll.dll';

const
  { NtQueryInformationThread Flags = https://www.geoffchappell.com/studies/windows/km/ntoskrnl/api/ps/psquery/class.htm }
  ThreadBasicInformation : DWORD = $00000000;

  { OpenThread Flags = https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-openthread }
  ThreadQueryInformation : DWORD = $00000040;

implementation

function GetThreadStacktop(hProcess : THandle; ThreadId : DWORD) : DWORD;
var
  hOpenThread : THandle;
  _InfoThread : THREAD_BASIC_INFORMATION;
  _hTibThread : _NT_TIB;
begin
  hOpenThread := OpenThread(ThreadQueryInformation, FALSE, ThreadId);
  try
    if (hOpenThread <> 0) then begin
      if NtQueryInformationThread(hOpenThread, ThreadBasicInformation, @_InfoThread, SizeOf(_InfoThread), Nil) = 0 then begin
        ReadProcessMemory(hProcess, _InfoThread.TebBaseAddress, @_hTibThread, SizeOf(_InfoThread), PNativeUInt(Nil)^);
        if (_hTibThread.StackBase <> Nil) then begin
          Result := DWORD(_hTibThread.StackBase);
        end else begin
          Result := $00000000;
        end;
      end else begin
        Result := $00000000;
      end;
    end else begin
      Result := $00000000;
    end;
  finally
    CloseHandle(hOpenThread);
  end;
end;

procedure GetThreadStackPtrs(hProcess : THandle; ResultList : TStringList; ProcessId : DWORD);
type
  PDWORD      = ^DWORD;
  PArrayDWORD = ^TArrayDWORD;
  TArrayDWORD = Array[0..4096] Of DWORD;
var
  Index           : Integer;

  _ModuleInfo     : MODULEINFO;

  hThreadSnapshot : THandle;
  hThreadEntry    : TThreadEntry32;
  hThreadBoolean  : Boolean;

  dwStacktop      : DWORD64;
  dwResult        : DWORD64;
  dwBuffer        : PDWORD;
  dwBufferArray   : PArrayDWORD;
begin
  hThreadSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
  try
    GetModuleInformation(hProcess, GetModuleHandle('Kernel32.dll'), @_ModuleInfo, SizeOf(_ModuleInfo));
    if (hThreadSnapshot <> INVALID_HANDLE_VALUE) then begin
      hThreadEntry.dwSize := SizeOf(hThreadEntry);
      hThreadBoolean      := Thread32First(hThreadSnapshot, hThreadEntry);
      while (hThreadBoolean = True) do begin
        dwResult := $00000000;
        try
          if (hThreadEntry.th32OwnerProcessID = ProcessId) then begin
            dwStacktop := GetThreadStacktop(hProcess, hThreadEntry.th32ThreadID);
            if (dwStacktop <> 0) then begin
              GetMem(dwBuffer, SizeOf(TArrayDWORD));
              dwBufferArray := PArrayDWORD(dwBuffer);
              try
                ReadProcessMemory(hProcess, Ptr(dwStacktop - 4096), dwBuffer, 4096, PNativeUInt(Nil)^);
                for Index := (4096 div 4) - 1 downto 0 do begin
                  if (dwBufferArray[Index] >= DWORD(_ModuleInfo.lpBaseOfDll)) and (dwBufferArray[Index] <= DWORD(NativeUInt(_ModuleInfo.lpBaseOfDll) + _ModuleInfo.SizeOfImage)) then begin
                    dwResult := dwStacktop - 4096 + Cardinal(Index) * 4;
                    Break;
                  end;
                end;
              finally
                FreeMem(dwBuffer);
              end;
              ResultList.Add(IntToHex(dwResult));
            end;
          end;
        finally
          hThreadBoolean := Thread32Next(hThreadSnapshot, hThreadEntry);
        end;
      end;
    end;
  finally
    CloseHandle(hThreadSnapshot);
  end;
end;

end.
