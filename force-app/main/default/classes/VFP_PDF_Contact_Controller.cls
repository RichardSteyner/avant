public class VFP_PDF_Contact_Controller {
    
    public 	Attachment 	file 		{ set; get; }
	public 	Boolean 	hasPicture 	{ set; get; }
	private String		parentId 	{ set; get; }
    public List<Introductions__c> introductions {get; set;}
    public List<Scheduling__c> schedulings {get; set;}
    public List<clsContact> contactsRelationships {get; set;}
    
    public VFP_PDF_Contact_Controller(ApexPages.StandardController stdController) {
        this.parentId = String.escapeSingleQuotes(stdController.getId());
       	this.hasPicture = false;
       	       	
       	List<Attachment> attList = [ Select ParentId, Name, Id, ContentType, BodyLength 
       									From Attachment 
       									where ParentId =: this.parentId and name = 'Contact Picture' limit 1];
       	if( attList.size() > 0 ){
       		this.file 		= attList.get( 0 );
       		this.file.Body 	= Blob.valueOf('AuxString');
       		this.hasPicture = true;
       	}
        
        introductions = [SELECT Name, Contact__r.Name, Contact2__r.Name, Contact_3__r.Name, Type_of_Introduction__c, Introduction_Date__c
                         FROM Introductions__c 
                        WHERE Contact__c =: stdController.getId() OR Contact2__c =: stdController.getId() OR Contact_3__c =: stdController.getId()];
        
        schedulings = [ SELECT Name, Type__c, Lead__r.Name, Status__c,Confirmed_Date__c,Notes__c 
                        FROM Scheduling__c
                      	WHERE Complete__c=false AND (Participant_1__c =: stdController.getId() OR Participant_2__c =: stdController.getId() 
                                                        OR Participant_3__c =: stdController.getId() OR Participant_4__c =: stdController.getId()
                                                       	OR Participant_5__c =: stdController.getId() OR Participant_6__c =: stdController.getId())];
        
        loadRelationships(stdController.getId());
    }
    
    public void loadRelationships(String contactId){
        Map<String, Contact> contacts1 = new Map<String, Contact>();
        Map<String, List<Contact>> contacts2 = new Map<String, List<Contact>>();
        Map<String, List<Contact>> contacts3 = new Map<String, List<Contact>>();
        List<Contact> auxList = new List<Contact>();
        Set<String> auxIds1 = new Set<String>();
        Set<String> auxIds2 = new Set<String>();
        
        contactsRelationships = new List<clsContact>();
        
        for(Relationship__c r : [SELECT Id, Contact2__r.Id, Contact2__r.FirstName, Contact2__r.Job_Title__c,
                                        Contact2__r.LastName, Contact2__r.Email,Contact2__r.Company__c,Contact2__r.MailingCity,Contact2__r.MailingCountry,
                                        Contact1__c 
                                FROM    Relationship__c 
                                WHERE Contact1__c =: contactId ]){

            contacts1.put(r.Contact2__r.Id, new Contact(Id=r.Contact2__r.Id, 
                                                        FirstName=r.Contact2__r.FirstName, 
                                                        LastName=r.Contact2__r.LastName, 
                                                        Email=r.Contact2__r.Email,
                                                        Company__c=r.Contact2__r.Company__c,
                                                        MailingCity=r.Contact2__r.MailingCity,
                                                        MailingCountry=r.Contact2__r.MailingCountry,
                                                        Job_Title__c=r.Contact2__r.Job_Title__c));
        }
        
        for(Relationship__c r : [SELECT Id, Contact2__r.Id, Contact2__r.FirstName, Contact2__r.Job_Title__c,
                                        Contact2__r.LastName, Contact2__r.Email,Contact2__r.Company__c,Contact2__r.MailingCity,Contact2__r.MailingCountry, 
                                        Contact1__c 
                                FROM  Relationship__c 
                                WHERE Contact1__c IN: contacts1.keySet() AND Contact2__c !=: contactId ]){

            auxList = contacts2.get(r.Contact1__c)!=null ? contacts2.get(r.Contact1__c) : new List<Contact>();
            auxList.add(new Contact(Id=r.Contact2__r.Id, 
                                    FirstName=r.Contact2__r.FirstName, 
                                    LastName=r.Contact2__r.LastName, 
                                    Email=r.Contact2__r.Email,
                                    Company__c=r.Contact2__r.Company__c,
                                    MailingCity=r.Contact2__r.MailingCity,
                                    MailingCountry=r.Contact2__r.MailingCountry,
                                    Job_Title__c=r.Contact2__r.Job_Title__c));
            contacts2.put(r.Contact1__c, auxList);
            auxIds1.add(r.Contact2__r.Id);
        }
        
        for(Relationship__c r : [SELECT Id, Contact2__r.Id, Contact2__r.Job_Title__c,Contact2__r.FirstName, Contact2__r.LastName,Contact2__r.Email, 
                                        Contact2__r.Company__c,Contact2__r.MailingCity,Contact2__r.MailingCountry,
                                        Contact1__c 
                                FROM Relationship__c 
                                WHERE Contact1__c IN: auxIds1 ]){
                                    
            auxList = contacts3.get(r.Contact1__c)!=null ? contacts3.get(r.Contact1__c) : new List<Contact>();
            auxList.add(new Contact(Id=r.Contact2__r.Id, 
                                    FirstName=r.Contact2__r.FirstName, 
                                    LastName=r.Contact2__r.LastName, 
                                    Email=r.Contact2__r.Email,
                                    Company__c=r.Contact2__r.Company__c,
                                    MailingCity=r.Contact2__r.MailingCity,
                                    MailingCountry=r.Contact2__r.MailingCountry,
                                    Job_Title__c=r.Contact2__r.Job_Title__c));
            contacts3.put(r.Contact1__c, auxList);
            auxIds2.add(r.Contact2__r.Id);
        }
        
        for(Contact c1 : contacts1.values()){
            contactsRelationships.add(new clsContact('child', c1));
            if(contacts2.get(c1.Id)!=null){
                for(Contact c2 : contacts2.get(c1.Id)){
                    contactsRelationships.add(new clsContact('grandchild', c2));
                    if(contacts3.get(c2.Id)!=null){
                        for(Contact c3 : contacts3.get(c2.Id)){
                            contactsRelationships.add(new clsContact('greatgrandchild', c3));
                        }
                    }
                }
            }
        }
    }

    public String getFormattedDateWithDayOfMonthSuffix() {
        // get a date
        Date today = Date.today();

        // use some parameter substitution to build the string
        String formattedDate = String.format('{0} {1}, {2}', 
                                            new List<String>{ 
                                                getMonthName(today.month()), 
                                                today.day() + getDayOfMonthSuffix(today.day()), 
                                                String.valueOf(today.year()) 
                                            });

        return formattedDate;
    }

    public String getMonthName(Integer m){
        Switch on m {
            when 1 {
                return 'January';
            }
            when 2 {
                return 'February';
            }
            when 3 {
                return 'March';
            }
            when 4 {
                return 'April';
            }
            when 5 {
                return 'May';
            }
            when 6 {
                return 'June';
            }
            when 7 {
                return 'July';
            }
            when 8 {
                return 'August';
            }
            when 9 {
                return 'September';
            }
            when 10 {
                return 'October';
            }
            when 11 {
                return 'November';
            }
            when 12 {
                return 'December';
            }
            when else {
                return '';
            }
         }
    }

    public String getDayOfMonthSuffix(Integer n) {
        if (n == null) {
            return '';
        }

        if (n >= 11 && n <= 13) {
            return 'th';
        }

        Integer modResult = Math.mod(n, 10);        
        if (modResult == 1) { 
            return 'st'; 
        } else if (modResult == 2) { 
            return 'nd'; 
        } else if (modResult == 3) { 
            return 'rd'; 
        } else { 
            return 'th';
        }
    }
    
    public class clsContact {
        public String typeRelation {get; set;}
        public Contact contact {get; set;}
        
        public clsContact(String vTypeRelation, Contact vContact){
            typeRelation = vTypeRelation;
            contact = vContact;
        }
    }

}