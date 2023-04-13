package fi.koodattu.lunchmenuapp.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;

@Entity
@Table(name = "allergens")
@Data
public class LunchMenuAllergen {

    @Id
    @GeneratedValue
    private long id;

    @Column(name = "symbol")
    private String allergenSymbol;
}
