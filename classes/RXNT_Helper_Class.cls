public class RXNT_Helper_Class {
     
     public static RXNT_SOAP_API.RxntToken CreateToken(RXNT_SOAP_API.SingleSignonRxNTWebServiceSoap obj){ 
        RXNT_SOAP_API.RxntToken CreateTokenResult = new RXNT_SOAP_API.RxntToken();
        CreateTokenResult = obj.CreateToken('TestDoctor1','Password1!','DoctorLogin');
        System.debug('token'+CreateTokenResult);
        return CreateTokenResult;
        
    }
}