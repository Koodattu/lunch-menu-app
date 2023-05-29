package fi.koodattu.lunchmenuapp.model;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "allergens", schema = "public")
public class LunchMenuAllergen {

    @Id
    @GeneratedValue
    private long id;

    @Column(name = "symbol")
    private String allergenSymbol;
}
