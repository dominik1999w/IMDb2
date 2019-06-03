package Types;

public class PeopleType {
    private Integer person_id;
    private String first_name;
    private String last_name;
    private String born;
    private String died;
    private String birth_country;
    private String identifier;

    public Integer getPerson_id() {
        return person_id;
    }

    public String getFirst_name() {
        return first_name;
    }

    public String getLast_name() {
        return last_name;
    }

    public String getBorn() {
        return born;
    }

    public void setBorn(String born) {
        this.born = born;
    }

    public String getDied() {
        return died;
    }

    public void setDied(String died) {
        this.died = died;
    }

    public String getBirth_country() {
        return birth_country;
    }

    public PeopleType(Integer person_id, String first_name, String last_name, String born, String died, String birth_country) {
        this.person_id = person_id;
        this.first_name = first_name;
        this.last_name = last_name;
        this.born = born;
        this.died = died;
        this.birth_country = birth_country;
        this.identifier = first_name + " " + last_name + " (" + born.substring(0,4) + ")";
    }

    public String getIdentifier() {
        return identifier;
    }
}
