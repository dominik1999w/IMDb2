package Management;

import java.io.ObjectInputStream;
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

    static ArrayList<Object> convertArrayIntoPreparedConsistent(ArrayList<Object> arrayList){
        for(int i = 0; i < arrayList.size(); i++){
            if(arrayList.get(i) instanceof String)
                arrayList.set(i, convertIntoPreparedConsistent((String) arrayList.get(i)));
        }
        return arrayList;
    }

    public static String convertIntoPreparedConsistent(String string){
        if(string.charAt(0) == '\'') {
            return string;
        } else
            return '\'' + string + '\'';
    }

}
