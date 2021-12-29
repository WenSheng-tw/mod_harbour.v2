/*
** hw_apache.prg -- Apache harbour module V2
** (c) DHF, 2020-2021
** MIT license
*/


#ifdef __PLATFORM__WINDOWS
#include "externs.hbx"
#endif

#include "hbthread.ch"
#include "hbclass.ch"

#define CRLF hb_OsNewLine()

THREAD STATIC request_rec
THREAD STATIC _cBuffer_Out 	:= ''


FUNCTION Main()


  
RETURN NIL

//	------------------------------------------------------------------	//

FUNCTION HW_Thread( r )

   LOCAL cFileName
   LOCAL pThreadWait
   LOCAL oHrb

   request_rec := r

   ErrorBlock( {| oError | GetErrorInfo( oError ), Break( oError ) } )

   pThreadWait := hb_threadStart( @HW_RequestMaxTime(), hb_threadSelf(), 15 ) // 15 Sec max

   cFileName = AP_FileName()  // HW_FileName()

   IF File( cFileName )

      IF Lower( Right( cFileName, 4 ) ) == ".hrb"

         hb_hrbDo( hb_hrbLoad( 2, cFileName ), AP_Args() )  // HW_Args()

      ELSE

         hb_SetEnv( "PRGPATH", ;
            SubStr( cFileName, 1, RAt( "/", cFileName ) + RAt( "\", cFileName ) - 1 ) )
         cCode := MemoRead( cFileName )

         Execute( cCode, AP_Args() ) // HW_Execute( cCode )

      ENDIF

   ELSE

      HW_EXITSTATUS( 404 )

   ENDIF

   while( hb_threadQuitRequest( pThreadWait ) )
      hb_idleSleep( 0.01 )
   ENDDO   
   
   AP_RPuts_Out( _cBuffer_Out )

RETURN

// ----------------------------------------------------------------//

FUNCTION GetRequestRec()

RETURN request_rec

// ----------------------------------------------------------------//

FUNCTION HW_RequestMaxTime( pThread, nTime )

   hb_idleSleep( nTime )

   while( hb_threadQuitRequest( pThread ) )
      hb_idleSleep( 0.01 )
   ENDDO

RETURN


// ----------------------------------------------------------------//

FUNCTION AP_RPUTS( ... )
  
   LOCAL aParams := hb_AParams()
   LOCAL n 		 := Len( aParams )
   
   IF n == 0
	  RETURN NIL
   ENDIF

   FOR i = 1 TO n - 1 
      _cBuffer_Out += valtochar( aParams[ i ] ) + ' '
   NEXT

   _cBuffer_Out += valtochar( aParams[ n ] )
   
_d( 'ap_rputs', _cBuffer_Out )   

RETURN

// ----------------------------------------------------------------//