/*By passing the record Id value you can get the complete json as string using apex even get the name fields of Lookups or Master Detail
@Author : Kodanda Pavan Sai
*/
public class jsonRecord {
    public static string getRecordDetails(Id Ids){
        try{
            Id recordId = Ids;
            String sObjectName = recordId.getSObjectType().getDescribe().getName();
            String query = 'SELECT ';
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
            for (String fieldName : fieldMap.keySet()) {
                query += fieldName + ', ';
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                Schema.DisplayType fieldType = fieldDescribe.getType();
                If(String.ValueOf(fieldType) == 'REFERENCE' && (fieldName.toLowerCase() != 'activitymetricid' && fieldName.toLowerCase() != 'masterrecordid')){
                    if(fieldName.endsWith('__c')){
                        string referenceField = fieldName.removeEndIgnoreCase('__c');
                        string relationFieldName = referenceField+'__r.Name';
                        query += relationFieldName + ', ';
                    }
                    else{
                        string referenceField = fieldName.removeEndIgnoreCase('id');
                        string relationFieldName = referenceField+'.Name';
                        query += relationFieldName + ', ';
                    }
                }
            }
            query = query.subString(0, query.length() - 2);
            query += ' FROM ' + sObjectName + ' WHERE Id = :recordId LIMIT 1';
            system.debug('query'+query);
            List<SObject> records = Database.query(query);
            String StringValue;
            List<String> returningRecordValue = new List<String>();
            Boolean ignoreNulls = true;
            if(ignoreNulls){
                StringValue = String.ValueOf(JSON.serialize(records[0]));
                StringValue = StringValue.replaceAll('\"[^\"]*\":null',''); //basic removeal of null values
                StringValue = StringValue.replaceAll(',{2,}', ','); //remove duplicate/multiple commas
                StringValue = StringValue.replace('{,', '{'); //prevent opening brace from having a comma after it
                StringValue = StringValue.replace(',}', '}'); //prevent closing brace from having a comma before it
                StringValue = StringValue.replace('[,', '['); //prevent opening bracket from having a comma after it
                StringValue = StringValue.replace(',]', ']'); //prevent closing bracket from having a comma before it
                returningRecordValue.add(StringValue);
            } else {
                StringValue = String.ValueOf(JSON.serialize(records[0]));
                returningRecordValue.add(StringValue);
            }
            system.debug(returningRecordValue[0]);
            return returningRecordValue;
        }
        catch(exception ex){
            SFA_LogException.log(ex);
            return null;
        }
    }
}
