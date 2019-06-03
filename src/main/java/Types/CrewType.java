package Types;

public class CrewType {
    private Integer movie_id;
    private Integer person_id;
    private String role;
    private String character;

    public CrewType(Integer person_id, String role, String character) {
        this.person_id = person_id;
        this.role = role;
        this.character = character;
    }

    public CrewType(String role, Integer movie_id, String character) {
        this.movie_id = movie_id;
        this.role = role;
        this.character = character;
    }

    public Integer getPerson_id() {
        return person_id;
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

    public Integer getMovie_id() {
        return movie_id;
    }

    public void setMovie_id(Integer movie_id) {
        this.movie_id = movie_id;
    }
}
