public class RXNT_Save_Patient_Queueable implements Queueable, Database.AllowsCallouts {
    public  String FirstName;
    public  String LastName;
    public  String DateOfBirth;
    public  String Sex;
    public  Id accountId;
    public RXNT_SOAP_API.SingleSignonRxNTWebServiceSoap obj = new RXNT_SOAP_API.SingleSignonRxNTWebServiceSoap();
    public RXNT_Save_Patient_Queueable(String FirstName, String LastName,  String DateOfBirth, String Sex, Id accountId ) {
        this.FirstName = FirstName;
        this.LastName = LastName;
        this.DateOfBirth = DateOfBirth;
        this.Sex=Sex;
        this.accountId=accountId;
    }
    
    public void execute(QueueableContext context) {
        RXNT_SOAP_API.RxntToken tokenObj = RXNT_Helper_Class.CreateToken(this.obj);
        system.debug('tokenObj'+tokenObj);
        RXNT_SOAP_API.RxntPatient pobj = new RXNT_SOAP_API.RxntPatient();
        pobj.FirstName= this.FirstName;
        pobj.LastName= this.LastName;
        pobj.Language='enNoneSpecified';
        pobj.InsuranceType='enNone';
        pobj.PatientEthnicity='enNoneSpecified';
        pobj.PatientRace=0;
        pobj.PatientFlag = '0';
        pobj.DoctorId = tokenObj.Doctor.DoctorId;
        pobj.PatientId = 0;
        pobj.DateOfBirth =  this.DateOfBirth;
        pobj.Sex = 'U';
        RXNT_SOAP_API.Address add =  new RXNT_SOAP_API.Address();
        RXNT_SOAP_API.Contact  con=  new RXNT_SOAP_API.Contact();
        pobj.Contact = con;
        pobj.Address = add;
        RXNT_SOAP_API.BasicDoctor dobj = new RXNT_SOAP_API.BasicDoctor();
        dobj.DoctorId=tokenObj.Doctor.DoctorId;
        dobj.DoctorGroupId=tokenObj.Doctor.DoctorGroupId;
        dobj.DoctorGroupName=tokenObj.Doctor.DoctorGroupName;
        dobj.DoctorCompanyId=tokenObj.Doctor.DoctorCompanyId;
        
        System.debug('pobj'+pobj);
        System.debug('dobj'+dobj);
        RXNT_SOAP_API.RxntPatient patientResult =  obj.SavePatient(tokenObj.token,pobj,dobj);
        System.debug('patientResult'+patientResult.PatientId);
        updateAccount(accountId,patientResult.PatientId);
        
    }
    
    public static RXNT_SOAP_API.RxntToken CreateToken(RXNT_SOAP_API.SingleSignonRxNTWebServiceSoap obj){ 
        RXNT_SOAP_API.RxntToken CreateTokenResult = new RXNT_SOAP_API.RxntToken();
        CreateTokenResult = obj.CreateToken('TestDoctor1','Password1!','DoctorLogin');
        System.debug('token'+CreateTokenResult);
        return CreateTokenResult;
        
    }
    
    public static void updateAccount(Id accountId ,  Long PatientId){
        
        Account acc = [Select PatientId__c from Account where Id = :accountId];
        acc.PatientId__c = PatientId;
        update acc;
    }
}