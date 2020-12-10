@IsTest
public class VFP_PDF_Contact_Controller_Test {

    public static testMethod void pictureAndUploadOther(){
        
        Contact myContact = new Contact(FirstName='Richard', LastName='Urupeque');
	    insert myContact;

	    Attachment myAttachment = new Attachment();
        myAttachment.Body = Blob.valueOf('String');
        myAttachment.ParentId = myContact.Id;
        myAttachment.Name = 'Contact Picture';
        insert myAttachment;

        Contact contactRel1 = new Contact(FirstName='Test', LastName='Rel1');
        insert contactRel1;
        Contact contactRel2 = new Contact(FirstName='Test', LastName='Rel2');
	    insert contactRel2;
        Contact contactRel3 = new Contact(FirstName='Test', LastName='Rel3');
	    insert contactRel3;

        Relationship__c rel1 = new Relationship__c(Contact1__c=myContact.Id, Contact2__c=contactRel1.Id);
        insert rel1;
        Relationship__c rel2 = new Relationship__c(Contact1__c=contactRel1.Id, Contact2__c=contactRel2.Id);
        insert rel2;
        Relationship__c rel3 = new Relationship__c(Contact1__c=contactRel2.Id, Contact2__c=contactRel3.Id);
        insert rel3;
        
	    Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController( myContact );
        VFP_PDF_Contact_Controller cTest = new VFP_PDF_Contact_Controller( sc );
        cTest.getFormattedDateWithDayOfMonthSuffix();
	    Test.stopTest();
	}
    
}
