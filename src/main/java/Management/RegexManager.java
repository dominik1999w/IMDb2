package Management;

public class RegexManager {

    public static boolean isSafe(String s){
        char[] array = s.toCharArray();
        for (char c : array) {
            if (!Character.isAlphabetic(c)
                    && !Character.isWhitespace(c)
                    && !Character.isDigit(c))
                return false;
        }

        return true;
    }


}
