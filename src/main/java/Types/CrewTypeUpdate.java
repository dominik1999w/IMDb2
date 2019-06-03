package Types;

public class CrewTypeUpdate {
    private String identifier;
    private Integer distictConstructors;
    private String identifier2;
    private String role;
    private String character;

    public CrewTypeUpdate(String identifier, String role, String character) {
        this.identifier = identifier;
        this.role = role;
        this.character = character;
    }

    public CrewTypeUpdate(Integer distictConstructors, String identifier2, String role, String character) {
        this.distictConstructors = distictConstructors;
        this.identifier2 = identifier2;
        this.role = role;
        this.character = character;
    }

    public String getIdentifier2() {
        return identifier2;
    }

    public String getIdentifier() {
        return identifier;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getCharacter() {
        return character;
    }

    public void setCharacter(String character) {
        this.character = character;
    }
}
