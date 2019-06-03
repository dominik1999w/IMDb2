package Management;

import java.util.ArrayList;
import java.util.Vector;

public class RegexManager {

    public static boolean isSafe(String s) {
        char[] array = s.toCharArray();
        for (char c : array) {
            if (!Character.isAlphabetic(c)
                    && !Character.isWhitespace(c)
                    && !Character.isDigit(c)
                    && c != '.'
                    && c != ',')
                return false;
        }

        return true;
    }

    public static String convertIntoList(Vector<String> vector){
        if(vector.size() == 0) return " - ";
        StringBuilder stringBuilder = new StringBuilder();
        for(String s : vector){
            stringBuilder.append(s).append(", ");
        }
        stringBuilder.deleteCharAt(stringBuilder.length() - 2);
        return stringBuilder.toString();
    }

    public static String convertIntoListNewLine(Vector<String> vector, boolean beautiful){
        if(vector.size() == 0) return beautiful ? " - " : "";
        StringBuilder stringBuilder = new StringBuilder();
        for(String s : vector){
            stringBuilder.append(s).append("\n");
        }
        stringBuilder.deleteCharAt(stringBuilder.length() - 1);
        return stringBuilder.toString();
    }

    static void convertArrayIntoPreparedConsistent(ArrayList<Object> arrayList){
        for(int i = 0; i < arrayList.size(); i++){
            if(arrayList.get(i) instanceof String)
                arrayList.set(i, convertIntoPreparedConsistent((String) arrayList.get(i)));
        }
    }

    public static String convertIntoPreparedConsistent(String string){
        if("".equals(string) || string == null)
            return null;
        if(string.charAt(0) == '\'') {
            return string;
        } else
            return '\'' + string + '\'';
    }

    public static Vector<String> convertStringToVector(String string){
        Vector<String> result = new Vector<>();
        try {
            while (!"".equals(string)) {
                int position = string.indexOf('\n');
                if (position < 0) position = string.length();
                result.add(string.substring(0, position));
                string = string.substring(position + 1);
            }
            return result;
        } catch (StringIndexOutOfBoundsException e){
            return result;
        }
    }

}
