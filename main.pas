unit main;
interface

{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}

uses
  SysUtils, commontestbase;

const
    _in = 'A Test';
    _inUTF8 = 'äöüß€';

type

  { TGraalNonUTF8 }

  TGraalNonUTF8 = class(TCommonTestSuiteCase)
  public
    procedure TestCase(name : String); override;
  end;

  { TGraalUTF8 }

  TGraalUTF8 = class(TCommonTestSuiteCase)
  public
    procedure TestCase(name : String); override;
  end;

  { TGraalNonUTF8 }

  { TGraalAddUTF8NonUTF8 }

  TGraalAddUTF8NonUTF8 = class(TCommonTestSuiteCase)
  public
    procedure TestCase(name : String); override;
  end;

  { TGraalUTF8 }

  { TGraalAddUTF8UTF8 }

  TGraalAddUTF8UTF8 = class(TCommonTestSuiteCase)
  public
    procedure TestCase(name : String); override;
  end;

  { TGraalUTF8Tests }

  TGraalUTF8Tests = class(TCommonTestSuite)
  private
    GraalNonUTF8: TGraalNonUTF8;
    GraalUTF8: TGraalUTF8;
    GraalAddUTF8NonUTF8: TGraalAddUTF8NonUTF8;
    GraalAddUTF8UTF8: TGraalAddUTF8UTF8;
  public
    constructor Create; override;
  end;

  {
   * Structure representing an isolate. A pointer to such a structure can be
   * passed to an entry point as the execution context.
    }
  graal_isolate_t = record
      {undefined structure}
    end;
  Pgraal_isolate_t = ^graal_isolate_t;
{
 * Structure representing a thread that is attached to an isolate. A pointer to
 * such a structure can be passed to an entry point as the execution context,
 * requiring that the calling thread has been attached to that isolate.
  }
  graal_isolatethread_t = record
      {undefined structure}
    end;
  Pgraal_isolatethread_t = ^graal_isolatethread_t;


  graal_uword = uint64;
  Pgraal_uword = ^graal_uword;
{
 * These constants can be used for the pkey field in the
 * graal_create_isolate_params_t struct to either specify that the isolate is
 * not part of a protection domain or a new protection domain should be
 * created for it.
  }

  int64array = array[0..MaxInt] of int64;
  PInt64Array = ^int64array;

const
  {$ifdef WIN64}
    External_library = 'libtestutf8.dll';
  {$else}
    {$ifdef darwin}
      External_library = 'libtestutf8.dylib';
      {$linklib libtestutf8}
    {$else}
      External_library = 'libtestutf8.so';
    {$endif}
  {$endif}
  NO_PROTECTION_DOMAIN = 0;
  NEW_PROTECTION_DOMAIN = -(1);
{ Parameters for the creation of a new isolate.  }
   __graal_create_isolate_params_version = 4;

  { Version of this struct  }
  { Fields introduced in version 1  }
  { Size of address space to reserve  }
  { Fields introduced in version 2  }
(* Const before type ignored *)
  { Path to an auxiliary image to load.  }
  { Reserved bytes for loading an auxiliary image.  }
  { Fields introduced in version 3  }
  { Internal usage, do not use.  }
  { Internal usage, do not use.  }
  { Isolate protection key or domain.  }
  { Fields introduced in version 4  }
  { Internal usage, do not use.  }
  { Internal usage, do not use.  }

  type
    graal_create_isolate_params_t = record
        version : longint;
        reserved_address_space_size : graal_uword;
        auxiliary_image_path : Pchar;
        auxiliary_image_reserved_space_size : graal_uword;
        _reserved_1 : longint;
        _reserved_2 : ^Pchar;
        pkey : longint;
        _reserved_3 : char;
        _reserved_4 : char;
      end;
    Pgraal_create_isolate_params_t = ^graal_create_isolate_params_t;

  type
    Pgraal_environment = ^graal_environment;
    graal_environment = record
        isolate : Pgraal_isolate_t;
        thread : Pgraal_isolatethread_t;
        mainthread : Pgraal_isolatethread_t;
      end;
  {
   * Create a new isolate, considering the passed parameters (which may be NULL).
   * Returns 0 on success, or a non-zero value on failure.
   * On success, the current thread is attached to the created isolate, and the
   * address of the isolate and the isolate thread are written to the passed pointers
   * if they are not NULL.
    }
  function graal_create_isolate(params:Pgraal_create_isolate_params_t; out isolate:Pgraal_isolate_t; out thread:Pgraal_isolatethread_t): longint;cdecl;external External_library name 'graal_create_isolate';
  {
   * Attaches the current thread to the passed isolate.
   * On failure, returns a non-zero value. On success, writes the address of the
   * created isolate thread structure to the passed pointer and returns 0.
   * If the thread has already been attached, the call succeeds and also provides
   * the thread's isolate thread structure.
    }

  function graal_attach_thread(isolate:Pgraal_isolate_t; var thread:Pgraal_isolatethread_t):longint;cdecl;external External_library name 'graal_attach_thread';

  {
   * Given an isolate to which the current thread is attached, returns the address of
   * the thread's associated isolate thread structure.  If the current thread is not
   * attached to the passed isolate or if another error occurs, returns NULL.
    }
  function graal_get_current_thread(isolate:Pgraal_isolate_t):Pgraal_isolatethread_t;cdecl;external External_library name 'graal_get_current_thread';

  {
   * Given an isolate thread structure, determines to which isolate it belongs and returns
   * the address of its isolate structure. If an error occurs, returns NULL instead.
    }
  function graal_get_isolate(thread:Pgraal_isolatethread_t):Pgraal_isolate_t;cdecl;external External_library name 'graal_get_isolate';

  {
   * Detaches the passed isolate thread from its isolate and discards any state or
   * context that is associated with it. At the time of the call, no code may still
   * be executing in the isolate thread's context.
   * Returns 0 on success, or a non-zero value on failure.
    }
  function graal_detach_thread(thread:Pgraal_isolatethread_t):longint;cdecl;external External_library name 'graal_detach_thread';

  {
   * Tears down the isolate of the passed (and still attached) isolate thread,
   * waiting for any attached threads to detach from it, then discards its objects,
   * threads, and any other state or context that is associated with it.
   * Returns 0 on success, or a non-zero value on failure.
    }
  function graal_tear_down_isolate(isolateThread:Pgraal_isolatethread_t):longint;cdecl;external External_library name 'graal_tear_down_isolate';

  {
   * In the isolate of the passed isolate thread, detach all those threads that were
   * externally started (not within Java, which includes the "main thread") and were
   * attached to the isolate afterwards. Afterwards, all threads that were started
   * within Java undergo a regular shutdown process, followed by the tear-down of the
   * entire isolate, which detaches the current thread and discards the objects,
   * threads, and any other state or context associated with the isolate.
   * None of the manually attached threads targeted by this function may be executing
   * Java code at the time when this function is called or at any point in the future
   * or this will cause entirely undefined (and likely fatal) behavior.
   * Returns 0 on success, or a non-zero value on (non-fatal) failure.
    }
  function graal_detach_all_threads_and_tear_down_isolate(isolateThread:Pgraal_isolatethread_t):longint;cdecl;external External_library name 'graal_detach_all_threads_and_tear_down_isolate';

  function print_and_return(isolateThread:Pgraal_isolatethread_t; _in:PChar):PChar;cdecl;external External_library name 'print_and_return';

  function add_utf8_print_and_return(isolateThread:Pgraal_isolatethread_t; _in:PChar):PChar;cdecl;external External_library name 'add_utf8_print_and_return';

  function create_graalvm_isolate(var env:graal_environment):longint;

  function attach_graalvm_thread(var env:graal_environment):longint;

  procedure RegisterTests;

var
  graal_environ: graal_environment;
  GraalUTF8Tests: TGraalUTF8Tests;

implementation

uses LazLoggerBase, TestRegistry;

{
 * Load dll using the default setting in SaxonC
 * Recommended method to use to load library
  }
function create_graalvm_isolate(var env:graal_environment):longint;
begin
  Result := 1;
  if (graal_create_isolate(nil, env.isolate, env.thread) <> 0) then
  begin
    DebugLn('graal_create_isolate error');
    Exit;
  end;
  env.mainthread := env.thread;
  DebugLn('main thread pointer %p\n', [Pointer(env.thread)]);
  Result := 0;
end;

function attach_graalvm_thread(var env:graal_environment):longint;
var
  newthread: Pgraal_isolatethread_t;
begin
    Result := 1;
    newthread := graal_get_current_thread(env.isolate);
    if Assigned(newthread) then
    begin
        DebugLn('Cur attach thread pointer same %p\n', [Pointer(newthread)]);
        env.thread := newthread;
        Result := 0;
        Exit;
    end;

    if (graal_attach_thread(env.isolate, newthread) <> 0) then
    begin
        DebugLn('graal_attach_thread error\n');
        Exit;
    end;
    DebugLn('graal_attach_thread pointer %p\n', [Pointer(newthread)]);
    env.thread := newthread;
    Result := 0;
end;

procedure RegisterTests;
begin
  GraalUTF8Tests := TGraalUTF8Tests.Create;
  RegisterTest('Graal UTF-8 Tests', GraalUTF8Tests);
end;

{ TGraalAddUTF8UTF8 }

procedure TGraalAddUTF8UTF8.TestCase(name: String);
var
  res: string;
begin
  res := add_utf8_print_and_return(graal_environ.thread, _inUTF8);
  AssertEquals('Result should match input:' + _inUTF8, '“' + _inUTF8 + '”', res);
end;

{ TGraalAddUTF8NonUTF8 }

procedure TGraalAddUTF8NonUTF8.TestCase(name: String);
var
  res: string;
begin
  res := add_utf8_print_and_return(graal_environ.thread, _in);
  AssertEquals('Result should match input:' + _in, '“' + _in + '”', res);
end;

{ TGraalUTF8 }

procedure TGraalUTF8.TestCase(name: String);
var
  res: string;
begin
  res := print_and_return(graal_environ.thread, _inUTF8);
  AssertEquals('Result should match input:' + _inUTF8, _inUTF8, res);
end;

{ TGraalNonUTF8 }

procedure TGraalNonUTF8.TestCase(name: String);
var
  res: string;
begin
  res := print_and_return(graal_environ.thread, _in);
  AssertEquals('Result should match input:' + _in, _in, res);
end;

{ TGraalUTF8Tests }

constructor TGraalUTF8Tests.Create;
begin
  inherited Create;
  GraalNonUTF8 := TGraalNonUTF8.Create('Graal string without UTF-8: ' + _in);
  AddTest(GraalNonUTF8);
  GraalUTF8 := TGraalUTF8.Create('Graal string with UTF-8: ' + _inUTF8);
  AddTest(GraalUTF8);
  GraalAddUTF8NonUTF8 := TGraalAddUTF8NonUTF8.Create('Graal string without UTF-8, Java adds UTF-8: ' + '“' + _in + '”');
  AddTest(GraalAddUTF8NonUTF8);
  GraalAddUTF8UTF8 := TGraalAddUTF8UTF8.Create('Graal string with UTF-8, Java adds UTF-8: ' + '“' + _inUTF8 + '”');
  AddTest(GraalAddUTF8UTF8);
end;

initialization
  create_graalvm_isolate(graal_environ);
  attach_graalvm_thread(graal_environ);

finalization

end.
